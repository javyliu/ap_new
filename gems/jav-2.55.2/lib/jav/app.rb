module Jav
  class App
    include Jav::Concerns::FetchesThings

    class_attribute :resources, default: []
    class_attribute :dashboards, default: []
    class_attribute :cache_store, default: nil
    class_attribute :fields, default: []
    class_attribute :request, default: nil
    class_attribute :context, default: nil
    class_attribute :license, default: nil
    class_attribute :current_user, default: nil
    class_attribute :root_path, default: nil
    class_attribute :view_context, default: nil
    class_attribute :params, default: {}
    class_attribute :translation_enabled, default: false
    class_attribute :error_messages

    class << self
      def eager_load(entity)
        paths = Jav::ENTITIES.fetch entity

        return if paths.blank?

        pathname = Rails.root.join(*paths)
        return unless pathname.directory?

        Rails.autoloaders.main.eager_load_dir(pathname.to_s)
      end

      def boot
        init_fields

        self.cache_store = Jav.configuration.cache_store
      end

      # Generate a dynamic root path using the URIService
      def root_path(paths: [], query: {}, **args)
        Jav::Services::URIService.parse(view_context.jav.root_url.to_s)
                                 .append_paths(paths)
                                 .append_query(query)
                                 .to_s
      end

      def init(request:, context:, current_user:, view_context:, params:)
        self.error_messages = []
        self.context = context
        self.current_user = current_user
        self.params = params
        self.request = request
        self.view_context = view_context

        self.license = {}
        self.translation_enabled = true

        # Set the current host for ActiveStorage
        begin
          if defined?(ActiveStorage::Current)
            if Rails::VERSION::MAJOR === 6
              ActiveStorage::Current.host = request.base_url
            elsif Rails::VERSION::MAJOR === 7
              ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
            end
          end
        rescue StandardError => exception
          Rails.logger.debug { "[Jav] Failed to set ActiveStorage::Current.url_options, #{exception.inspect}" }
        end

        check_bad_resources
        init_resources
        init_dashboards
      end

      # This method will find all fields available in the Jav::Fields namespace and add them to the fields class_variable array
      # so later we can instantiate them on our resources.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Jav::Fields::TextField -> text
      # Jav::Fields::DateTimeField -> date_time
      def init_fields
        Jav::Fields::BaseField.descendants.each do |class_name|
          next if class_name.to_s == "BaseField"

          load_field class_name.field_name, class_name if class_name.to_s.end_with? "Field"
        end
      end

      def load_field(method_name, klass)
        fields.push(
          name: method_name,
          class: klass
        )
      end

      def check_bad_resources
        resources.each do |resource|
          has_model = resource.model_class.present?

          next if has_model

          possible_model = resource.class.to_s.gsub "Resource", ""

          Jav::App.error_messages.push({
                                         url: "https://docs.javhq.io/2.0/resources.html#custom-model-class",
                                         target: "_blank",
                                         message: "#{resource.class} does not have a valid model assigned. It failed to find the #{possible_model} model. \n\r Please create that model or assign one using self.model_class = YOUR_MODEL"
                                       })
        end
      end

      # Fetches the resources available to the application.
      # We have two ways of doing that.
      #
      # 1. Through eager loading.
      # We automatically eager load the resources directory and fetch the descendants from the scanned files.
      # This is the simple way to get started.
      #
      # 2. Manually, declared by the user.
      # We have this option to load the resources because when they are loaded automatically through eager loading,
      # those Resource classes and their methods may trigger loading other classes. And that may disrupt Rails booting process.
      # Ex: AdminResource may use self.model_class = User. That will trigger Ruby to load the User class and itself load
      # other classes in a chain reaction.
      # The scenario that comes up most often is when Rails boots, the routes are being computed which eager loads the resource files.
      # At that boot time some migration might have not been run yet, but Rails tries to access them through model associations,
      # and they are not available.
      #
      # To enable this feature add a `resources` array config in your Jav initializer.
      # config.resources = [
      #   "UserResource",
      #   "FishResource",
      # ]
      def fetch_resources
        resources = if Jav.configuration.resources.nil?
                      BaseResource.descendants
                    else
                      Jav.configuration.resources
                    end

        resources.map do |resource|
          if resource.is_a?(Class)
            resource
          else
            resource.to_s.safe_constantize
          end
        end
      end

      def init_resources
        self.resources = fetch_resources
                         .reject do |resource|
          # Remove the BaseResource. We only need the descendants
          resource == BaseResource
          # On invalid resource configuration the resource classes get duplicated in `ObjectSpace`
          # We need to de-duplicate them
        end
        self.resources = resources.uniq(&:name)
        self.resources = resources.map do |resource|
          resource.new if resource.is_a? Class
        end
      end

      def init_dashboards
        eager_load :dashboards unless Rails.application.config.eager_load

        self.dashboards = Dashboards::BaseDashboard.descendants
                                                   .reject do |dashboard|
          dashboard == Dashboards::BaseDashboard
        end.uniq(&:id)
      end

      def has_main_menu?
        return false if Jav.configuration.main_menu.nil?

        true
      end

      def has_profile_menu?
        return false if Jav.configuration.profile_menu.nil?

        true
      end

      def main_menu
        # Return empty menu if the app doesn't have the profile menu configured
        return Jav::Menu::Builder.new.build unless has_main_menu?

        Jav::Menu::Builder.parse_menu(&Jav.configuration.main_menu)
      end

      def profile_menu
        # Return empty menu if the app doesn't have the profile menu configured
        return Jav::Menu::Builder.new.build unless has_profile_menu?

        Jav::Menu::Builder.parse_menu(&Jav.configuration.profile_menu)
      end

      def debug_report(request = nil)
        payload = {}

        hq = Jav::Licensing::HQ.new(request)

        payload[:license_id] = Jav::App.license&.id
        payload[:license_valid] = Jav::App.license&.valid?
        payload[:license_payload] = Jav::App.license&.payload
        payload[:license_response] = Jav::App.license&.response
        payload[:hq_payload] = hq&.payload
        payload[:thread_count] = get_thread_count
        payload[:license_abilities] = Jav::App.license&.abilities
        payload[:cache_store] = cache_store&.class&.to_s
        payload[:jav_metadata] = hq&.jav_metadata
        payload[:app_timezone] = Time.current.zone
        payload[:cache_key] = Jav::Licensing::HQ.cache_key
        payload[:cache_key_contents] = hq&.cached_response

        payload
      rescue StandardError => e
        e
      end

      def get_thread_count
        Thread.list.count { |thread| thread.status == "run" }
      rescue StandardError => e
        e
      end
    end
  end
end
