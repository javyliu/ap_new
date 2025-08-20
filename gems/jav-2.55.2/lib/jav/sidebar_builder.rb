class Jav::SidebarBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  attr_reader :items_holder

  delegate :field, to: :items_holder
  delegate :items, to: :items_holder
  delegate :heading, to: :items_holder

  def initialize(name: nil, **args)
    @sidebar = Jav::Sidebar.new(**args)
    @items_holder = Jav::ItemsHolder.new
  end

  # Fetch the sidebar
  def build
    @sidebar.items_holder = @items_holder
    @sidebar
  end
end
