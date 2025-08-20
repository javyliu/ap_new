# frozen_string_literal: true

class Jav::TurboFrameWrapperComponent < ViewComponent::Base
  attr_reader :name

  def initialize(name = nil)
    super
    @name = name
  end
end
