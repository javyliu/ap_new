module Jav
  module Fields
    class HiddenField < TextField
      def initialize(id, **args, &block)
        super

        only_on %i[edit new]
      end
    end
  end
end
