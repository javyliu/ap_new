# frozen_string_literal: true

class Jav::PanelComponent < ViewComponent::Base
  attr_reader :title, :classes # deprecating title in favor of name

  delegate :white_panel_classes, to: :helpers

  renders_one :tools
  renders_one :body
  renders_one :sidebar
  renders_one :bare_sidebar
  renders_one :bare_content
  renders_one :footer_tools
  renders_one :footer

  def initialize(name: nil, description: nil, body_classes: nil, data: {}, display_breadcrumbs: false, index: nil, classes: nil, **args)
    super
    # deprecating title in favor of name
    @title = args[:title]
    @name = name || title
    @description = description
    @classes = classes
    @body_classes = body_classes
    @data = data
    @display_breadcrumbs = display_breadcrumbs
    @index = index
  end

  private

  def data_attributes
    @data.merge({ 'panel-index': @index })
  end

  def display_breadcrumbs?
    @display_breadcrumbs == true && Jav.configuration.display_breadcrumbs == true
  end

  def name
    if @name.respond_to?(:call)
      @name.call
    else
      @name
    end
  end

  def description
    if @description.respond_to?(:call)
      @description.call
    else
      @description.to_s
    end
  end

  def render_header?
    @name.present? || description.present? || tools.present? || display_breadcrumbs?
  end
end
