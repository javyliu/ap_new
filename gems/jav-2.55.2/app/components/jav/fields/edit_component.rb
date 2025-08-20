# frozen_string_literal: true

class Jav::Fields::EditComponent < ViewComponent::Base
  include Jav::ResourcesHelper

  attr_reader :compact, :field, :form, :index, :multiple, :resource, :stacked, :view

  def initialize(field: nil, resource: nil, index: 0, form: nil, compact: false, stacked: nil, multiple: false, **kwargs)
    super
    @compact = compact
    @field = field
    @form = form
    @index = index
    @multiple = multiple
    @resource = resource
    @stacked = stacked
    @view = :edit
  end

  def classes(extra_classes = "")
    helpers.input_classes("#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}", has_error: @field.model_errors.include?(@field.id))
  end

  def render?
    !field.computed
  end

  def field_wrapper_args
    {
      compact: compact,
      field: field,
      form: form,
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
