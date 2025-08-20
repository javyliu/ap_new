class Jav::Panel
  include Jav::Concerns::IsResourceItem
  include Jav::Concerns::VisibleItems

  class_attribute :item_type, default: :panel

  attr_reader :name, :view, :description
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil, view: nil)
    @name = name
    @view = view
    @description = description
    @items_holder = Jav::ItemsHolder.new
  end

  def has_items?
    @items.present?
  end
end
