module Jav
  module Fields
    class CodeField < BaseField
      attr_reader :language, :theme, :height, :tab_size, :indent_with_tabs, :line_wrapping

      def initialize(id, **args, &block)
        hide_on :index

        super

        @language = args[:language].present? ? args[:language].to_s : "javascript"
        @theme = args[:theme].present? ? args[:theme].to_s : "default"
        @height = args[:height].present? ? args[:height].to_s : "auto"
        @tab_size = args[:tab_size].presence || 2
        @indent_with_tabs = args[:indent_with_tabs].presence || false
        @line_wrapping = args[:line_wrapping].presence || true
      end
    end
  end
end
