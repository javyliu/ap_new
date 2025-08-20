class Jav::Menu::Builder
  class << self
    def parse_menu(&block)
      Docile.dsl_eval(Jav::Menu::Builder.new, &block).build
    end
  end

  delegate :context, to: ::Jav::App
  delegate :current_user, to: ::Jav::App
  delegate :params, to: ::Jav::App
  delegate :request, to: ::Jav::App
  delegate :root_path, to: ::Jav::App
  delegate :view_context, to: ::Jav::App
  delegate :main_app, to: :view_context
  delegate :jav, to: :view_context

  def initialize(name: nil, items: [])
    @menu = Jav::Menu::Menu.new

    @menu.name = name
    @menu.items = items
  end

  # Adds a link
  def link(name, path = nil, **args)
    path ||= args[:path]
    @menu.items << Jav::Menu::Link.new(name: name, path: path, **args)
  end
  alias link_to link

  # Validates and adds a resource
  def resource(name, **args)
    name = name.to_s.singularize
    res = Jav::App.guess_resource(name)

    return if res.blank?

    @menu.items << Jav::Menu::Resource.new(resource: name, **args)
  end
  alias resources resource

  # Adds a dashboard
  def dashboard(dashboard, **args)
    @menu.items << Jav::Menu::Dashboard.new(dashboard: dashboard, **args)
  end

  # Adds a section
  def section(name = nil, **args, &block)
    @menu.items << Jav::Menu::Section.new(name: name, **args, items: self.class.parse_menu(&block).items)
  end

  # Adds a group
  def group(name = nil, **args, &block)
    @menu.items << Jav::Menu::Group.new(name: name, **args, items: self.class.parse_menu(&block).items)
  end

  # Add all the resources
  def all_resources(**args)
    Jav::App.resources_for_navigation.each do |res|
      resource res.route_key, **args
    end
  end

  # Add all the dashboards
  def all_dashboards(**args)
    Jav::App.dashboards_for_navigation.each do |dash|
      dashboard dash.id, **args
    end
  end

  # Add all the tools
  def all_tools(**args)
    Jav::App.tools_for_navigation.each do |tool|
      link tool.humanize, path: root_path(paths: [tool])
    end
  end

  # Fetch the menu
  def build
    @menu
  end
end
