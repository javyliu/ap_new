# This concern helps us figure out what items are visible for each tab, panel or sidebar
module Jav
  module Concerns
    module VisibleItems
      extend ActiveSupport::Concern
      def items
        if items_holder.present?
          items_holder.items
        else
          []
        end
      end

      def visible_items
        items.map do |item|
          item.hydrate(view: view) if item.respond_to? :hydrate

          visible(item) ? item : nil
        end
          .compact
      end

      def visible(item)
        return item.visible? unless item.is_field?

        return false if item.respond_to?(:authorized?) && item.resource.present? && !item.authorized?

        item.visible? && item.visible_on?(view)
      end

      def visible?
        any_item_visible = visible_items.any?
        return any_item_visible unless respond_to?(:visible_on?)

        visible_on?(view) && any_item_visible
      end

      def hydrate(view: nil)
        @view = view

        self
      end
    end
  end
end
