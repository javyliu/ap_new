require "rails/generators"

module Generators
  module Jav
    class VersionGenerator < ::Rails::Generators::Base
      namespace "jav:version"

      def handle
        if defined? ::Jav::Engine
          output "Jav #{::Jav.configuration.license} #{::Jav::VERSION}"
        else
          output "Jav not installed."
        end
      end

      private

      def output(message)
        puts message unless options["quiet"]
      end
    end
  end
end
