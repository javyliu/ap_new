# frozen_string_literal: true

class Jav::BaseComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def has_with_trial(ability)
    ::Jav::App.license.has_with_trial(ability)
  end

  private

  # Use the @parent_resource to fetch the field using the @reflection name.
  def field
    @parent_resource.get_field_definitions.find { |f| f.id == @reflection.name }
  rescue StandardError
    nil
  end

  # Fetch the resource and hydrate it with the model
  def association_resource
    resource = ::Jav::App.get_resource(params[:via_resource_class])
    model_class_name = params[:via_relation_class] || resource.model_class

    model_klass = ::Jav::BaseResource.valid_model_class model_class_name

    resource = ::Jav::App.get_resource_by_model_name model_klass if resource.blank?

    model = resource.find_record params[:via_resource_id], query: model_klass, params: params

    resource.dup.hydrate model: model
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_resource
    ::Jav::App.get_resource_by_model_name(@reflection.klass.to_s)
  rescue StandardError
    nil
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_parent_resource
    ::Jav::App.get_resource_by_model_name(@reflection.active_record.to_s)
  rescue StandardError
    nil
  end

  def parent_or_child_resource
    return @resource unless link_to_child_resource_is_enabled?
    return @resource if @resource.model.class.base_class == @resource.model.class

    ::Jav::App.get_resource_by_model_name(@resource.model.class).dup || @resource
  end

  def link_to_child_resource_is_enabled?
    return field_linked_to_child_resource? if @parent_resource

    @resource.link_to_child_resource
  end

  def field_linked_to_child_resource?
    field.present? && field.respond_to?(:link_to_child_resource) && field.link_to_child_resource
  end
end
