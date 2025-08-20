module Jav
  module Fields
    class MarkdownField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super

        hide_on :index

        @always_show = args[:always_show].presence || false
        @height = args[:height].present? ? args[:height].to_s : "auto"
        @spell_checker = args[:spell_checker].presence || false
        @options = {
          spell_checker: @spell_checker,
          always_show: @always_show,
          height: @height
        }
      end
    end
  end
end
