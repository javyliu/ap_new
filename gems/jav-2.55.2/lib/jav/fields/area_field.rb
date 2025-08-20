# frozen_string_literal: true

module Jav
  module Fields
    class AreaField < BaseField
      attr_reader :mapkick_options, :datapoint_options

      def initialize(id, **args, &block)
        hide_on :index

        super

        @geometry = args[:geometry].presence || :polygon # Accepts: `:polygon` or `:multi_polygon`
        @mapkick_options = args[:mapkick_options].presence || {}
        @datapoint_options = args[:datapoint_options].presence || {}
      end

      def map_data
        data_source = {
          geometry: {
            type: @geometry.to_s.classify,
            coordinates: value
          }
        }

        [data_source.merge(datapoint_options)]
      end

      def coordinates
        value.present? ? JSON.parse(value) : []
      end

      def geometry
        @geometry.to_s.classify
      end
    end
  end
end
