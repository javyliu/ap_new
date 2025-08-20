# frozen_string_literal: true

class Jav::Index::TableRowComponent < ViewComponent::Base
  include Jav::ResourcesHelper

  def initialize(resource: nil, reflection: nil, parent_model: nil, parent_resource: nil)
    super
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
  end
end
