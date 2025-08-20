# frozen_string_literal: true

class Jav::LoadingComponent < ViewComponent::Base
  def initialize(title: nil)
    super
    @title = title
  end
end
