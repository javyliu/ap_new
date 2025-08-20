class Jav::Tab
  include Jav::Concerns::IsResourceItem
  include Jav::Concerns::VisibleItems
  include Jav::Fields::FieldExtensions::VisibleInDifferentViews

  class_attribute :item_type, default: :tab
  delegate :items, :add_item, to: :items_holder

  attr_reader :view, :identity_name
  attr_accessor :description, :items_holder, :holds_one_field

  def initialize(name: nil, description: nil, view: nil, holds_one_field: false, **args)
    # Initialize the visibility markers
    super

    @name = name
    @description = description
    @holds_one_field = holds_one_field
    @items_holder = Jav::ItemsHolder.new
    @view = view

    show_on args[:show_on] if args[:show_on].present?
    hide_on args[:hide_on] if args[:hide_on].present?
    only_on args[:only_on] if args[:only_on].present?
    except_on args[:except_on] if args[:except_on].present?
    @identity_name = args[:identity_name]
  end

  def name
    if @name.respond_to?(:call)
      Jav::Hosts::BaseHost.new(block: @name).handle
    else
      @name
    end
  end

  def hydrate(view: nil)
    @view = view

    items_holder.items.grep(Jav::Panel).each do |panel|
      panel.hydrate(view: view)
    end

    self
  end

  def turbo_frame_id(parent: nil)
    id = "#{Jav::Tab.to_s.parameterize} #{name} #{@identity_name}".parameterize

    return id if parent.nil?

    "#{parent.turbo_frame_id} #{id}".parameterize
  end

  def empty?
    visible_items.blank?
  end

  # Checks for visibility on itself or on theone field it holds
  def visible_on?(view)
    if holds_one_field
      super && items.first.visible_on?(view)
    else
      super
    end
  end

  def has_a_single_item?
    items.count == 1
  end
end
