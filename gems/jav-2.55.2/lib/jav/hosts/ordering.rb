require "dry-initializer"

module Jav
  module Hosts
    class Ordering
      extend Dry::Initializer

      option :options, default: proc { {} }
      option :resource
      option :record, default: proc { resource.model }
      option :params, default: proc { resource.params }

      def order(direction)
        action = options.dig(:actions, direction.to_sym)

        return if action.blank?

        instance_exec(&action)
      end
    end
  end
end
