module Jav
  module Concerns
    module HasEditableControls
      extend ActiveSupport::Concern

      included do
        class_attribute :show_controls
        class_attribute :show_controls_holder
        class_attribute :show_controls_holder_called, default: false
      end

      def has_show_controls?

        self.class.show_controls.present?
      end

      def render_show_controls

        if show_controls.present?
          Jav::Resources::Controls::ExecutionContext.new(
            block: show_controls,
            resource: self,
            record: model,
            view: view
          ).handle&.items || []
        else
          []
        end
      end
    end
  end
end
