module Jav
  module Fields
    class NumberField < TextField
      attr_reader :min, :max, :step

      def initialize(id, **args, &block)
        super

        @min = args[:min].present? ? args[:min].to_f : nil
        @max = args[:max].present? ? args[:max].to_f : nil
        @step = args[:step].present? ? args[:step].to_f : nil
      end
    end
  end
end
