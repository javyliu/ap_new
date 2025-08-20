require_dependency "jav/base_controller"

module Jav
  class AssociationsController < BaseController
    before_action :set_model, only: %i[show index new create destroy order]
    before_action :hydrate_resource, only: %i[show index new create destroy order]
    before_action :set_related_resource_name
    before_action :set_related_resource, only: %i[show index new create destroy order]
    before_action :set_related_authorization
    before_action :set_reflection_field
    before_action :set_related_model, only: %i[show order]
    before_action :hydrate_related_resource, only: %i[show index create destroy order]
    before_action :set_reflection
    before_action :set_attachment_class, only: %i[show index new create destroy order]
    before_action :set_attachment_resource, only: %i[show index new create destroy order]
    before_action :set_attachment_model, only: %i[create destroy order]
    before_action :authorize_index_action, only: :index
    before_action :authorize_attach_action, only: :new
    before_action :authorize_detach_action, only: :destroy

    def index
      @parent_resource = @resource.dup
      @resource = @related_resource
      @parent_model = @parent_resource.find_record(params[:id], params: params)
      @parent_resource.hydrate(model: @parent_model)
      association_name = BaseResource.valid_association_name(@parent_model, params[:related_name])
      @query = @related_authorization.apply_policy @parent_model.send(association_name)
      @association_field = @parent_resource.get_field params[:related_name]

      @query = Jav::Hosts::AssociationScopeHost.new(block: @association_field.scope, query: @query, parent: @parent_model).handle if @association_field.present? && @association_field.scope.present?

      super
    end

    def show
      @parent_resource = @resource
      @parent_model = @model

      @resource = @related_resource
      @model = @related_model

      super
    end

    def new
      @resource.hydrate(model: @model)

      return unless @field.present? && !@field.searchable

      query = @related_authorization.apply_policy @attachment_class

      # Add the association scope to the query scope
      query = Jav::Hosts::AssociationScopeHost.new(block: @field.attach_scope, query: query, parent: @model).handle if @field.attach_scope.present?

      @options = query.all.map do |model|
        val = @attachment_resource.class.title.is_a?(Proc) ? Jav::ExecutionContext.new(target: @attachment_resource.class.title, resource: @attachment_resource, record: model).handle : model.send(@attachment_resource.class.title)
        [val, model.id]
      end
    end

    def create
      association_name = BaseResource.valid_association_name(@model, params[:related_name])

      if has_many_reflection?
        @model.send(association_name) << @attachment_model
      else
        @model.send(:"#{association_name}=", @attachment_model)
      end

      respond_to do |format|
        if @model.save
          format.html { redirect_back fallback_location: resource_view_response_path, notice: t("jav.attachment_class_attached", attachment_class: @related_resource.name) }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      association_name = BaseResource.valid_association_name(@model, params[:related_name])

      if has_many_reflection?
        @model.send(association_name).delete @attachment_model
      else
        @model.send(:"#{association_name}=", nil)
      end

      respond_to do |format|
        format.html { redirect_to params[:referrer] || resource_view_response_path, notice: t("jav.attachment_class_detached", attachment_class: @attachment_class) }
      end
    end

    def order
      @parent_resource = @resource.dup
      @resource = @related_resource
      @model = @related_model

      super
    end

    private

    def set_reflection
      @reflection = @model.class.reflect_on_association(params[:related_name])
    end

    def set_attachment_class
      @attachment_class = @reflection.klass
    end

    def set_attachment_resource
      @attachment_resource = @field.use_resource || (App.get_resource_by_model_name @attachment_class)
    end

    def set_attachment_model
      @attachment_model = @related_resource.find_record attachment_id, params: params
    end

    def set_reflection_field
      @field = @resource.get_field_definitions.find { |f| f.id == @related_resource_name.to_sym }
      @field.hydrate(resource: @resource, model: @model, view: :new)
    rescue StandardError
    end

    def attachment_id
      params[:related_id] || params.require(:fields).permit(:related_id)[:related_id]
    end

    def reflection_class
      if @reflection.is_a?(ActiveRecord::Reflection::ThroughReflection)
        @reflection.through_reflection.class
      else
        @reflection.class
      end
    end

    def authorize_if_defined(method)
      @authorization.set_record(@model)

      return unless @authorization.has_method?(method.to_sym)

      @authorization.authorize_action method.to_sym
    end

    def authorize_index_action
      authorize_if_defined "view_#{@field.id}?"
    end

    def authorize_attach_action
      authorize_if_defined "attach_#{@field.id}?"
    end

    def authorize_detach_action
      authorize_if_defined "detach_#{@field.id}?"
    end

    def set_related_authorization
      @related_authorization = if related_resource
                                 related_resource.authorization(user: _current_user)
                               else
                                 Services::AuthorizationService.new _current_user
                               end
    end

    def has_many_reflection?
      reflection_class.in? [
        ActiveRecord::Reflection::HasManyReflection,
        ActiveRecord::Reflection::HasAndBelongsToManyReflection
      ]
    end
  end
end
