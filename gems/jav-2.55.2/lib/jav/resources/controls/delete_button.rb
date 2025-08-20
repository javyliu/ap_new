module Jav
  module Resources
    module Controls
      class DeleteButton < BaseControl
        def initialize(**args)
          super

          @label = I18n.t("jav.delete").capitalize
        end
      end
    end
  end
end
