module Jav
  module Licensing
    class NilLicense < License
      def initialize(response = nil)
        response ||= {
          id: "community",
          valid: true
        }

        super
      end
    end
  end
end
