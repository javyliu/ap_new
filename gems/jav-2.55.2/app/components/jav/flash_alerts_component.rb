# frozen_string_literal: true

class Jav::FlashAlertsComponent < ViewComponent::Base
  include Jav::ApplicationHelper

  def initialize(flashes: [])
    super
    @flashes = flashes
  end
end
