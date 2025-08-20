module Jav
  module Fields
    class IdField < BaseField
      attr_reader :link_to_resource

      def initialize(id, **args, &block)
        args[:readonly] = true

        hide_on %i[edit new]

        super

        add_boolean_prop args, :sortable, true

        @link_to_resource = args[:link_to_resource].presence || false
      end
    end
  end
end
