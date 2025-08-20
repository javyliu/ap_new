module Jav
  module Fields
    class FilesField < BaseField
      attr_accessor :is_audio, :is_image, :direct_upload, :accept
      attr_reader :display_filename, :view_type, :hide_view_type_switcher

      def initialize(id, **args, &block)
        super

        @is_audio = args[:is_audio].presence || false
        @is_image = args[:is_image].presence || @is_avatar
        @direct_upload = args[:direct_upload].presence || false
        @accept = args[:accept].presence
        @display_filename = args[:display_filename].nil? ? true : args[:display_filename]
        @view_type = args[:view_type] || :grid
        @hide_view_type_switcher = args[:hide_view_type_switcher]
      end

      def view_component_name
        "FilesField"
      end

      def to_permitted_param
        { "#{id}": [] }
      end

      def fill_field(model, key, value, params)
        return model unless model.methods.include? key.to_sym

        value.each do |file|
          # Skip empty values
          next if file.blank?

          model.send(key).attach file
        end

        model
      end
    end
  end
end
