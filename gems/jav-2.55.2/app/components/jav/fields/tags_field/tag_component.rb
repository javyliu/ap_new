# frozen_string_literal: true

class Jav::Fields::TagsField::TagComponent < ViewComponent::Base
  attr_reader :label, :title

  def initialize(label: nil, title: nil)
    @label = label
    @title = title
  end
end
