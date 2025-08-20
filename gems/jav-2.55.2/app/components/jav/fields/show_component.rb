# frozen_string_literal: true

class Jav::Fields::ShowComponent < ViewComponent::Base
  include Jav::ResourcesHelper

  attr_reader :compact, :field, :index, :resource, :stacked, :view

  def initialize(field: nil, resource: nil, index: 0, form: nil, compact: false, stacked: nil)
    super
    @compact = compact
    @field = field
    @index = index
    @resource = resource
    @stacked = stacked
    @view = :show
  end

  def wrapper_data
    {
      **stimulus_attributes
    }
  end

  def stimulus_attributes
    attributes = {}

    if @resource.present?
      @resource.get_stimulus_controllers.split.each do |controller|
        attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
      end
    end

    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
    attributes.merge! wrapper_data_attributes if wrapper_data_attributes.present?

    attributes
  end

  def field_wrapper_args
    {
      compact: compact,
      field: field,
      index: index,
      resource: resource,
      stacked: stacked,
      view: view
    }
  end

  def disabled?
    field.is_readonly? || field.is_disabled?
  end
end
