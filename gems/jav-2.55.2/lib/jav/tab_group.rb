class Jav::TabGroup
  include Jav::Concerns::HasFields
  include Jav::Concerns::IsResourceItem

  class_attribute :item_type, default: :tab_group

  attr_reader :view
  attr_accessor :index, :items_holder, :style

  def initialize(index: 0, view: nil, style: nil)
    @index = index
    @items_holder = Jav::ItemsHolder.new
    @view = view
    @style = style
  end

  def hydrate(view: nil)
    @view = view

    self
  end

  def visible_items
    items
      .map { |item| item.hydrate view: view }
      .select { |item| item.visible_on? view } # Remove items hidden in this view
      .reject(&:empty?) # Remove empty items
  end

  def turbo_frame_id
    "#{Jav::TabGroup.to_s.parameterize} #{index}".parameterize
  end
end
