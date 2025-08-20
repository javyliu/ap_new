module Jav
  module Fields
    class PasswordField < TextField
      def initialize(id, **args, &block)
        show_on :forms

        super

        hide_on %i[index show]
      end
    end
  end
end
