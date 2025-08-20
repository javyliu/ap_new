require "rails/generators"

module Generators
  module Jav
    class BaseGenerator < ::Rails::Generators::Base
      hide!

      def initialize(*args)
        super(*args)

        # Don't output the version if requested so
        unless args.include?(["--skip-jav-version"])
          invoke "jav:version", *args
        end
      end
    end
  end
end
