# frozen_string_literal: true

class Jav::PaginatorComponent < ViewComponent::Base
  attr_reader :pagy, :turbo_frame, :index_params, :resource, :parent_model, :discreet_pagination

  def initialize(resource: nil, parent_model: nil, pagy: nil, turbo_frame: nil, index_params: nil, discreet_pagination: nil)
    super
    @pagy = pagy
    @turbo_frame = turbo_frame
    @index_params = index_params
    @resource = resource
    @parent_model = parent_model
    @discreet_pagination = discreet_pagination
  end

  def change_items_per_page_url(option)
    if parent_model.present?
      helpers.related_resources_path(parent_model, parent_model, per_page: option, keep_query_params: true, page: 1)
    else
      helpers.resources_path(resource: resource, per_page: option, keep_query_params: true, page: 1)
    end
  end

  def render?
    return false if discreet_pagination && pagy.pages <= 1

    @pagy.limit.positive?
  end

  def per_page_options
    @per_page_options ||= begin
      options = [*Jav.configuration.per_page_steps, Jav.configuration.per_page.to_i, index_params[:per_page].to_i]

      options.prepend Jav.configuration.via_per_page if parent_model.present?

      options.sort.uniq
    end
  end
end
