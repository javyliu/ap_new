# frozen_string_literal: true

class Jav::RowComponent < ViewComponent::Base
  attr_reader :classes

  renders_one :body

  def initialize(classes: nil, data: {})
    super
    @classes = classes
    @data = data
  end
end
