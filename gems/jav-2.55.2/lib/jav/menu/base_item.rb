require "dry-initializer"

class Jav::Menu::BaseItem
  extend Dry::Initializer

  option :collapsable, default: proc { false }
  option :collapsed, default: proc { false }
  option :icon, optional: true
  option :items, default: proc { [] }
  option :name, default: proc { "" }
  option :visible, default: proc { true }
  option :data, default: proc { {} }

  def visible?
    return visible if visible.in? [true, false]

    return false unless visible.respond_to? :call

    Jav::Hosts::BaseHost.new(block: visible).handle
  end

  def navigation_label
    label || entity_label
  end
end
