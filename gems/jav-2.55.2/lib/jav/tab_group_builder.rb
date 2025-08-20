class Jav::TabGroupBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  attr_reader :items_holder

  delegate :tab, to: :items_holder

  def initialize(style: nil)
    @group = Jav::TabGroup.new(style: style)
    @items_holder = Jav::ItemsHolder.new
  end

  def field(field_name, **args, &block)
    parsed = Jav::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse
    field_instance = parsed.instance

    name = -> { field_instance.name }
    tab = Jav::Tab.new name: name

    if field_instance.has_own_panel?
      tab.items_holder.add_item parsed.instance
      tab.holds_one_field = true
    else
      # If the field is not in a panel, create one and add it
      panel = Jav::Panel.new name: name
      panel.items_holder.add_item parsed.instance
      # Add that panel to the bag
      tab.items_holder.add_item panel
    end

    @items_holder.tabs tab
  end

  # Fetch the tab
  def build
    @group.items_holder = @items_holder
    @group
  end
end
