module Jav
  module Resources
    module Controls
      class DetachButton < BaseControl
        def initialize(**args)
          super

          @label = I18n.t("jav.detach_item", item: title).humanize
        end
      end
    end
  end
end
