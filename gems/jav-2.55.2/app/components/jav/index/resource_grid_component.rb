# frozen_string_literal: true

class Jav::Index::ResourceGridComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil)
    super
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
  end
end
