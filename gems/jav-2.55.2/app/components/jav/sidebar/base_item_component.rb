# frozen_string_literal: true

class Jav::Sidebar::BaseItemComponent < ViewComponent::Base
  attr_reader :item

  def initialize(item: nil)
    @item = item
  end

  delegate :items, to: :item

  def key
    result = "jav.#{request.host}.main_menu.#{item.name.to_s.underscore}"

    result += ".#{item.icon.parameterize.underscore}" if item.icon.present?

    result
  end

  delegate :collapsable, to: :item

  delegate :collapsed, to: :item
end
