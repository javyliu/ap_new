module Jav
  module Fields
    class TextField < BaseField
      attr_reader :link_to_resource, :as_html, :protocol

      def initialize(id, **args, &block)
        super

        add_boolean_prop args, :link_to_resource
        add_boolean_prop args, :as_html
        add_string_prop args, :protocol
      end
    end
  end
end
