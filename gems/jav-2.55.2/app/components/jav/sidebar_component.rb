# frozen_string_literal: true

class Jav::SidebarComponent < ViewComponent::Base
  def initialize(sidebar_open: nil, for_mobile: false)
    super
    @sidebar_open = sidebar_open
    @for_mobile = for_mobile
  end

  def dashboards
    Jav::App.dashboards_for_navigation
  end

  def resources
    Jav::App.resources_for_navigation
  end

  def tools
    Jav::App.tools_for_navigation
  end

  def stimulus_target
    @for_mobile ? "mobileSidebar" : "sidebar"
  end
end
