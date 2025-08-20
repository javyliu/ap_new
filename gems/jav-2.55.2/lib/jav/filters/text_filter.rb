module Jav
  module Filters
    class TextFilter < BaseFilter
      class_attribute :button_label

      self.template = "jav/base/text_filter"

      def selected_value(applied_filters)
        applied_or_default_value
      end
    end
  end
end
