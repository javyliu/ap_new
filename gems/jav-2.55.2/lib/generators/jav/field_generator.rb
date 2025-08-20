require_relative "named_base_generator"

module Generators
  module Jav
    class FieldGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "jav:field"
      desc "Add a custom Jav field to your project."

      def handle
        directory "field/components", "#{::Jav.configuration.view_component_path}/jav/fields/#{singular_name}_field"
        template "field/%singular_name%_field.rb.tt", "app/jav/fields/#{singular_name}_field.rb"
      end
    end
  end
end
