# frozen_string_literal: true

class Jav::Sidebar::HeadingComponent < ViewComponent::Base
  attr_reader :collapsable, :collapsed, :icon, :key, :label

  def initialize(label: nil, icon: nil, collapsable: false, collapsed: false, key: nil)
    @collapsable = collapsable
    @collapsed = collapsed
    @icon = icon
    @key = key
    @label = label
  end
end
