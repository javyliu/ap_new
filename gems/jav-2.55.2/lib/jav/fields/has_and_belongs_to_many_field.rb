module Jav
  module Fields
    class HasAndBelongsToManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on Jav.configuration.resource_default_view

        super
      end

      def view_component_name
        "HasManyField"
      end
    end
  end
end
