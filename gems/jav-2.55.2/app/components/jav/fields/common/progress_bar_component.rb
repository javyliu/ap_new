# frozen_string_literal: true

class Jav::Fields::Common::ProgressBarComponent < ViewComponent::Base
  attr_reader :value, :display_value, :value_suffix, :max, :view

  def initialize(value:, display_value: false, value_suffix: nil, max: 100, view: :index)
    @value = value
    @display_value = display_value
    @value_suffix = value_suffix
    @max = max
    @view = view
  end

  def show?
    view == :show
  end

  def index?
    view == :index
  end
end
