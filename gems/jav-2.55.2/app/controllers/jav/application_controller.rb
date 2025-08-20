module Jav
  class ApplicationController < ::ActionController::Base
    if defined?(Pundit::Authorization)
      Jav::ApplicationController.include Pundit::Authorization
    elsif defined?(Pundit)
      Jav::ApplicationController.include Pundit
    end

    include Jav::ApplicationHelper
    include Jav::UrlHelpers
    include Jav::Concerns::Breadcrumbs

    protect_from_forgery with: :exception
    around_action :set_jav_locale
    around_action :set_force_locale, if: -> { params[:force_locale].present? }
    before_action :set_default_locale, if: -> { params[:set_locale].present? }
    before_action :init_app
    before_action :set_resource_name
    before_action :_authenticate!
    before_action :set_authorization
    before_action :set_container_classes
    before_action :add_initial_breadcrumbs
    before_action :set_view
    before_action :set_sidebar_open

    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user, :resources_path, :resource_path, :new_resource_path, :edit_resource_path, :resource_attach_path, :resource_detach_path, :related_resources_path, :turbo_frame_request?, :resource_view_path
    add_flash_types :info, :warning, :success, :error

    def init_app
      Jav::App.init request: request, context: context, current_user: _current_user, view_context: view_context, params: params

      @license = Jav::App.license
    end

    def exception_logger(exception)
      respond_to do |format|
        format.html { raise exception }
        format.json do
          render json: {
            errors: exception.respond_to?(:record) && exception.record.present? ? exception.record.errors : [],
            message: exception.message,
            traces: exception.backtrace
          }, status: ActionDispatch::ExceptionWrapper.status_code_for_exception(exception.class.name)
        end
      end
    end

    # 因为没做任何操作，可以直接注释，如果对render 有额外的处理可以在子类重写
    # def render(*args)

    #   super
    # end

    def check_jav_license
      true
    end

    def _current_user
      instance_eval(&Jav.configuration.current_user)
    end

    def context
      instance_eval(&Jav.configuration.context)
    end

    # This is coming from Turbo::Frames::FrameRequest module.
    # Exposing it as public method
    # def turbo_frame_request?
    #   super
    # end
    # use module#public to exposing it as public method
    public :turbo_frame_request?

    private

    def set_resource_name
      @resource_name = resource_name
    end

    def set_related_resource_name
      @related_resource_name = related_resource_name
    end

    def set_resource
      raise ActionController::RoutingError, "No route matches" if resource.nil?

      @resource = resource.hydrate(params: params)
    end

    def set_related_resource
      @related_resource = related_resource.hydrate(params: params)
    end

    def set_model
      @model = @resource.find_record(params[:id], query: model_find_scope, params: params)
    end

    def model_find_scope
      eager_load_files(@resource, model_scope)
    end

    def model_scope
      @resource.class.find_scope
    end

    def set_related_model
      association_name = BaseResource.valid_association_name(@model, params[:related_name])
      @related_model = if @field.is_a? Jav::Fields::HasOneField
                         @model.send association_name
                       else
                         @related_resource.find_record params[:related_id], query: eager_load_files(@related_resource, @model.send(association_name)), params: params
                       end
    end

    def set_view
      @view = action_name.to_sym
    end

    def set_model_to_fill
      @model_to_fill = @resource.model_class.new if @view == :create
      @model_to_fill = @model if @view == :update

      # If resource.model is nil, most likely the user is creating a new record.
      # In that case, to access resource.model in visible and readonly blocks we hydrate the resource with a new model.
      @resource.hydrate(model: @model_to_fill) if @resource.model.nil?
    end

    def fill_model
      # We have to skip filling the the model if this is an attach action
      is_attach_action = params[model_param_key].blank? && params[:related_name].present? && params[:fields].present?

      return if is_attach_action

      @model = @resource.fill_model(@model_to_fill, cast_nullable(model_params), extra_params: extra_params)
    end

    def hydrate_resource
      @resource.hydrate(view: action_name.to_sym, user: _current_user, model: @model)
    end

    def hydrate_related_resource
      @related_resource.hydrate(view: action_name.to_sym, user: _current_user, model: @related_model)
    end

    def authorize_base_action
      class_to_authorize = @model || @resource.model_class

      authorize_action class_to_authorize
    end

    def authorize_action(class_to_authorize, action = nil)
      # Use the provided action or figure it out from the request
      action_to_authorize = action || action_name

      @authorization.set_record(class_to_authorize).authorize_action action_to_authorize.to_sym
    end

    # Get the pluralized resource name for this request
    # Ex: projects, teams, users
    def resource_name
      return params[:resource_name] if params[:resource_name].present?

      return controller_name if controller_name.present?

      begin
        request.path
               .match(%r{/?#{Jav::App.root_path.delete('/')}/resources/([a-z1-9\-_]*)/?}mi)
               .captures
               .first
      rescue StandardError => e
        Rails.logger.error "method-resource_name: #{e.message}"
      end
    end

    def related_resource_name
      params[:related_name]
    end

    # Gets the Jav resource for this request based on the request from the `resource_name` "param"
    # Ex: Jav::Resources::Project, Jav::Resources::Team, Jav::Resources::User
    def resource
      resource = App.get_resource @resource_name.to_s.camelize.singularize

      return resource if resource.present?

      App.get_resource_by_controller_name @resource_name
    end

    def related_resource
      # Find the field from the parent resource
      field = @resource.get_field params[:related_name]

      return field.use_resource if field&.use_resource.present?

      reflection = @model.class.reflect_on_association(params[:related_name])

      reflected_model = reflection.klass

      App.get_resource_by_model_name reflected_model
    end

    def eager_load_files(resource, query)
      # Get the non-computed file fields and try to eager load them
      attachment_fields = resource
                          .attachment_fields
                          .reject(&:computed)

      # Jav::Fields::FileField or Jav::Fields::FilesField
      attachment_fields.presence&.map do |field|
        # attachment = case field.class.to_s
        #              when "Jav::Fields::FilesField"
        #                "attachments"
        #              else
        #                "attachment"
        #              end
        attachment = field.instance_of?(::Jav::Fields::FileField) ? "attachments" : "attachment"
        query.includes "#{field.id}_#{attachment}": :blob
      end

      query
    end

    def _authenticate!
      instance_eval(&Jav.configuration.authenticate)
    end

    def render_unauthorized(_exception)
      flash[:notice] = t "jav.not_authorized"

      redirect_url = if request.referer.blank? || (request.referer == request.url)
                       root_url
                     else
                       request.referer
                     end

      redirect_to(redirect_url)
    end

    def set_authorization
      # We need to set @resource_name for the #resource method to work properly
      set_resource_name
      @authorization = if resource
                         resource.authorization(user: _current_user)
                       else
                         Services::AuthorizationService.new _current_user
                       end
    end

    def set_container_classes
      contain = true

      contain = false if Jav.configuration.full_width_container || (Jav.configuration.full_width_index_view && action_name.to_sym == :index && self.class.superclass.to_s == "Jav::ResourcesController")

      @container_classes = contain ? "2xl:container 2xl:mx-auto" : ""
    end

    def add_initial_breadcrumbs
      instance_eval(&Jav.configuration.initial_breadcrumbs) if Jav.configuration.initial_breadcrumbs.present?
    end

    def on_root_path
      [Jav.configuration.root_path, "#{Jav.configuration.root_path}/"].include?(request.original_fullpath)
    end

    def on_resources_path
      request.original_url.match?(%r{.*#{Jav.configuration.root_path}/resources/.*})
    end

    def on_api_path
      request.original_url.match?(%r{.*#{Jav.configuration.root_path}/jav_api/.*})
    end

    def on_dashboards_path
      request.original_url.match?(%r{.*#{Jav.configuration.root_path}/dashboards/.*})
    end

    def on_debug_path
      request.original_url.match?(%r{.*#{Jav.configuration.root_path}/jav_private/debug.*})
    end

    def on_custom_tool_page
      !(on_root_path || on_resources_path || on_api_path || on_dashboards_path || on_debug_path)
    end

    def model_param_key
      @resource.form_scope
    end

    # Sets the locale set in jav.rb initializer
    def set_jav_locale(&action)
      locale = Jav.configuration.locale || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    # Enable the user to change the default locale with the `?set_locale=pt-BR` param
    def set_default_locale
      locale = params[:set_locale] || I18n.default_locale

      I18n.default_locale = locale
    end

    # Temporary set the locale and reverting at the end of the request.
    def set_force_locale(&action)
      locale = params[:force_locale] || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    def default_url_options
      if params[:force_locale].present?
        { **super, force_locale: params[:force_locale] }
      else
        super
      end
    end

    def set_sidebar_open
      value = cookies["#{Jav::COOKIES_KEY}.sidebar.open"]
      @sidebar_open = value.blank? || value == "1"
    end
  end
end
