require "dry-initializer"

module Jav
  module Hosts
    class DashboardVisibility
      extend Dry::Initializer

      option :block, default: proc { proc {} }
      option :current_user, default: proc { ::Jav::App.current_user }
      option :context, default: proc { ::Jav::App.context }
      option :dashboard
      option :params, default: proc { ::Jav::App.params }

      def handle
        instance_exec(&block)
      end
    end
  end
end
