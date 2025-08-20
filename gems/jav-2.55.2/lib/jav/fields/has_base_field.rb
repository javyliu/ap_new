module Jav
  module Fields
    class HasBaseField < BaseField
      include Jav::Fields::Concerns::UseResource

      attr_accessor :display, :scope, :attach_scope, :description, :discreet_pagination, :hide_search_input
      attr_reader :link_to_child_resource, :searchable

      def initialize(id, **args, &block)
        super

        @scope = args[:scope].presence
        @attach_scope = args[:attach_scope].presence
        @display = args[:display].presence || :show
        @searchable = args[:searchable] == true
        @hide_search_input = args[:hide_search_input] || false
        @description = args[:description]
        @use_resource = args[:use_resource] || nil
        @discreet_pagination = args[:discreet_pagination] || false
        @link_to_child_resource = args[:link_to_child_resource] || false
      end

      def resource
        @resource || Jav::App.get_resource_by_model_name(@model.class)
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{frame_id}"
      end

      def frame_url
        Jav::Services::URIService.parse(@resource.record_path)
                                 .append_path(id.to_s)
                                 .append_query(turbo_frame: turbo_frame.to_s)
                                 .to_s
      end

      # The value
      def field_value
        value.send(database_value)
      rescue StandardError
        nil
      end

      # What the user sees in the text field
      def field_label
        value.send(target_resource.class.title)
      rescue StandardError
        nil
      end

      def target_resource
        return use_resource if use_resource.present?

        if @model.class.reflect_on_association(id).klass.present?
          Jav::App.get_resource_by_model_name @model.class.reflect_on_association(id).klass.to_s
        elsif @model.class.reflect_on_association(id).options[:class_name].present?
          Jav::App.get_resource_by_model_name @model.class.reflect_on_association(id).options[:class_name]
        else
          Jav::App.get_resource_by_name id.to_s
        end
      end

      def placeholder
        @placeholder || I18n.t("jav.choose_an_option")
      end

      def has_own_panel?
        true
      end

      def visible_in_reflection?
        false
      end

      # Adds the view override component
      # has_one, has_many, has_and_belongs_to_many fields don't have edit views
      def component_for_view(view = :index)
        view = :show if view.in? %i[new create update edit]

        super
      end

      def authorized?
        method = :"view_#{id}?"
        service = resource.authorization

        if service.has_method? method
          service.authorize_action(method, raise_exception: false)
        else
          true
        end
      end

      def default_name
        use_resource&.name || super
      end

      private

      def frame_id
        use_resource.present? ? use_resource.route_key.to_sym : @id
      end

      def default_view
        Jav.configuration.skip_show_view ? :edit : :show
      end
    end
  end
end
