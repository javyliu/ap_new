# frozen_string_literal: true

class Jav::ResourceSidebarComponent < ViewComponent::Base
  attr_reader :resource, :params, :view, :form, :fields

  def initialize(resource: nil, fields: nil, index: nil, params: nil, form: nil, view: nil)
    super
    @resource = resource
    @fields = fields
    @params = params
    @view = view
    @form = form
  end

  def render?
    true
  end
end
