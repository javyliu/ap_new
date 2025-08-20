module Jav
  module Fields
    class ExternalImageField < BaseField
      attr_reader :width, :height, :radius, :link_to_resource

      def initialize(id, **args, &block)
        super

        @link_to_resource = args[:link_to_resource].presence || false

        @width = args[:width].presence || 40
        @height = args[:height].presence || 40
        @radius = args[:radius].presence || 0
      end

      def to_image
        value
      end
    end
  end
end
