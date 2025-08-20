module Jav
  module Dashboards
    class BaseDivider
      include Jav::Concerns::VisibleInDashboard

      attr_reader :dashboard, :label, :invisible, :index, :visible

      class_attribute :id

      def initialize(dashboard: nil, label: nil, invisible: false, index: nil, visible: true)
        @dashboard = dashboard
        @label = label
        @invisible = invisible
        @index = index
        @visible = visible
      end

      def is_divider?
        true
      end

      def is_card?
        false
      end

      def call_block
        ::Jav::Hosts::CardVisibility.new(block: visible, card: self, parent: dashboard).handle
      end
    end
  end
end
