require_relative "named_base_generator"

module Generators
  module Jav
    class ControllerGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "jav:controller"

      def create
        template "resource/controller.tt", "app/controllers/jav/#{controller_name}.rb"
      end

      private

      def controller_name
        "#{plural_name}_controller"
      end

      def controller_class
        "Jav::#{class_name.camelize.pluralize}Controller"
      end
    end
  end
end
