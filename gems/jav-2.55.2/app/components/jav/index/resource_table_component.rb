# frozen_string_literal: true

class Jav::Index::ResourceTableComponent < ViewComponent::Base
  include Jav::ApplicationHelper
  attr_reader :pagy, :query

  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, pagy: nil, query: nil)
    super
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
    @pagy = pagy
    @query = query
  end

  def encrypted_query
    return :select_all_disabled if query.nil? || !query.respond_to?(:all) || !query.all.respond_to?(:to_sql)

    Jav::Services::EncryptionService.encrypt(
      message: query.all.to_sql,
      purpose: :select_all
    )
  end

  def selected_page_label
    if @resource.pagination_type.countless?
      t "jav.x_records_selected_from_page_html", selected: pagy.in
    else
      t "jav.x_records_selected_from_a_total_of_x_html", selected: pagy.in, count: pagy.count
    end
  end

  def selected_all_label
    if @resource.pagination_type.countless?
      t "jav.records_selected_from_all_pages_html"
    else
      t "jav.x_records_selected_from_all_pages_html", count: pagy.count
    end
  end
end
