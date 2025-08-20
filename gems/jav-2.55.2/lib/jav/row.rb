class Jav::Row
  include Jav::Concerns::IsResourceItem
  include Jav::Concerns::VisibleItems

  class_attribute :item_type, default: :row

  attr_reader :view
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(view: nil)
    @view = view
    @items_holder = Jav::ItemsHolder.new
  end

  def hydrate(view: nil, **args)
    @view = view

    self
  end

  def has_items?
    @items.present?
  end
end
