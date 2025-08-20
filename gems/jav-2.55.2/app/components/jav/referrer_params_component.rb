# frozen_string_literal: true

class Jav::ReferrerParamsComponent < ViewComponent::Base
  attr_reader :back_path

  def initialize(back_path: nil)
    super
    @back_path = back_path
  end
end
