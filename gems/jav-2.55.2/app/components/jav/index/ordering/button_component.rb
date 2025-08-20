# frozen_string_literal: true

class Jav::Index::Ordering::ButtonComponent < Jav::Index::Ordering::BaseComponent
  attr_accessor :resource, :reflection, :direction, :svg

  def initialize(resource:, direction:, svg: nil, reflection: nil)
    @resource = resource
    @reflection = reflection
    @direction = direction
    @svg = svg
  end

  def render?
    order_actions[direction].present?
  end

  def order_path(args)
    Jav::App.view_context.jav.reorder_order_path(resource.route_key, resource.model.to_param, **args)
  end
end
