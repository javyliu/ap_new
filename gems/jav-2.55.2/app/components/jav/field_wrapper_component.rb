# frozen_string_literal: true

class Jav::FieldWrapperComponent < ViewComponent::Base
  attr_reader :dash_if_blank, :compact, :field, :form, :full_width, :resource, :view

  def initialize(
    dash_if_blank: true,
    data: {},
    compact: false,
    help: nil, # do we really need it?
    field: nil,
    form: nil,
    full_width: false,
    label: nil, # do we really need it?
    resource: nil,
    stacked: nil,
    style: "",
    view: :show,
    **args
  )
    super
    @args = args
    @classes = args[:class].presence || ""
    @dash_if_blank = dash_if_blank
    @data = data
    @compact = compact
    @help = help
    @field = field
    @form = form
    @full_width = full_width
    @label = label
    @resource = resource
    @action = field.action
    @stacked = stacked
    @style = style
    @view = view
  end

  def classes(extra_classes = "")
    "field-wrapper relative flex flex-col grow pb-2 md:pb-0 leading-tight min-h-14 h-full #{stacked? ? 'field-wrapper-layout-stacked' : 'field-wrapper-layout-inline md:flex-row md:items-center'} #{compact? ? 'field-wrapper-size-compact' : 'field-wrapper-size-regular'} #{full_width? ? 'field-width-full' : 'field-width-regular'} #{@classes || ''} #{extra_classes || ''} #{@field.get_html(:classes, view: view, element: :wrapper)}"
  end

  def style
    "#{@style} #{@field.get_html(:style, view: view, element: :wrapper)}"
  end

  def label
    @label || @field.name
  end

  def on_show?
    view == :show
  end

  def on_edit?
    view == :edit
  end

  def help
    help_value = @help || @field.help

    return Jav::Hosts::ResourceViewRecordHost.new(block: help_value, record: record, resource: resource, view: view).handle if help_value.respond_to?(:call)

    help_value
  end

  def record
    resource.present? ? resource.model : nil
  end

  def data
    attributes = {
      field_id: @field.id,
      field_type: @field.type,
      **@data
    }

    # Fetch the data attributes off the html option
    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
    attributes.merge! wrapper_data_attributes if wrapper_data_attributes.present?

    # Add the built-in stimulus integration data tags.
    add_stimulus_attributes_for(@resource, attributes) if @resource.present?

    add_stimulus_attributes_for(@action, attributes) if @action.present?

    attributes
  end

  def stacked?
    # Override on the declaration level
    return @stacked unless @stacked.nil?

    # Fetch it from the field
    return field.stacked unless field.stacked.nil?

    # Fallback to defaults
    Jav.configuration.field_wrapper_layout == :stacked
  end

  def compact?
    @compact
  end

  def full_width?
    @full_width
  end

  private

  def add_stimulus_attributes_for(entity, attributes)
    entity.get_stimulus_controllers.split.each do |controller|
      attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
    end
  end
end
