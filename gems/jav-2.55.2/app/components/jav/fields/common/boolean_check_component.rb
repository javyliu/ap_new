# frozen_string_literal: true

class Jav::Fields::Common::BooleanCheckComponent < ViewComponent::Base
  def initialize(checked: false)
    @checked = checked
  end
end
