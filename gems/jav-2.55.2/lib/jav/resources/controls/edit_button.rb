module Jav
  module Resources
    module Controls
      class EditButton < BaseControl
        def initialize(**args)
          super

          @label = I18n.t("jav.edit").capitalize
        end
      end
    end
  end
end
