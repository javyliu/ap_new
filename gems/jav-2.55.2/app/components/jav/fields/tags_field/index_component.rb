# frozen_string_literal: true

class Jav::Fields::TagsField::IndexComponent < Jav::Fields::IndexComponent
  include Jav::Fields::Concerns::ItemLabels

  def value
    @field.field_value
  end
end
