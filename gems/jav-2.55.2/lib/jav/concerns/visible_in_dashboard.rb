module Jav
  module Concerns
    module VisibleInDashboard
      extend ActiveSupport::Concern

      included do
        class_attribute :visible, default: true
      end

      def is_visible?
        # Default is true
        return true if visible == true

        # Hide if false
        return false if visible == false

        return false unless visible.respond_to? :call

        call_block
      end

      def is_hidden?
        !is_visible?
      end

      def call_block
        ::Jav::Hosts::DashboardVisibility.new(block: visible, dashboard: self).handle
      end
    end
  end
end
