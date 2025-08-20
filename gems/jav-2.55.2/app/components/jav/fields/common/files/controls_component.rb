# frozen_string_literal: true

class Jav::Fields::Common::Files::ControlsComponent < ViewComponent::Base
  include Jav::ApplicationHelper
  include Jav::Fields::Concerns::FileAuthorization

  attr_reader :file, :field, :resource
  delegate :id, to: :field

  def initialize(field:, file:, resource:)
    @field = field
    @file = file
    @resource = resource
  end

  def destroy_path
    Jav::Services::URIService.parse(@resource.record_path).append_paths("active_storage_attachments", id, file.id).to_s
  end
end
