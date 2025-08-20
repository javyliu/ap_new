module Jav
  module Fields
    class ProgressBarField < BaseField
      attr_reader :max, :step, :display_value, :value_suffix

      def initialize(name, **args, &block)
        super

        @max = args[:max] || 100
        @step = args[:step] || 1
        @display_value = args[:display_value] || false
        @value_suffix = args[:value_suffix] || nil
      end
    end
  end
end
