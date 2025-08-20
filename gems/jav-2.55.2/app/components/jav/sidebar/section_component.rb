# frozen_string_literal: true

class Jav::Sidebar::SectionComponent < Jav::Sidebar::BaseItemComponent
  def icon
    return nil if item.icon.nil?

    item.icon
  end
end
