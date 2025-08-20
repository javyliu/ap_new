# frozen_string_literal: true

class Jav::Fields::Common::KeyValueComponent < ViewComponent::Base
  include Jav::ApplicationHelper

  attr_reader :view

  def initialize(field:, form: nil, view: :show)
    @field = field
    @form = form
    @view = view
  end
end
