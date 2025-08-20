module Jav
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_resource, :is_avatar, :is_image, :is_audio, :direct_upload, :accept
      attr_reader :display_filename

      def initialize(id, **args, &block)
        super

        @link_to_resource = args[:link_to_resource].presence || false
        @is_avatar = args[:is_avatar].presence || false
        @is_image = args[:is_image].presence || @is_avatar
        @is_audio = args[:is_audio].presence || false
        @direct_upload = args[:direct_upload].presence || false
        @accept = args[:accept].presence
        @display_filename = args[:display_filename].nil? ? true : args[:display_filename]
      end

      def path
        rails_blob_url value
      end
    end
  end
end
