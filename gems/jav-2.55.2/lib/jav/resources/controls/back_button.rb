module Jav
  module Resources
    module Controls
      class BackButton < BaseControl
        def initialize(**args)
          super

          @label = I18n.t("jav.go_back")
        end
      end
    end
  end
end
