# frozen_string_literal: true

class Jav::Fields::Common::HeadingComponent < ViewComponent::Base
  attr_reader :value, :as_html, :empty

  def initialize(value:, as_html:, empty:)
    @value = value
    @as_html = as_html
    @empty = empty
  end
end
