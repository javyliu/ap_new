require_relative "named_base_generator"

module Generators
  module Jav
    class ActionGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      class_option :standalone, type: :boolean

      namespace "jav:action"

      def create_resource_file
        type = "resource"

        type = "standalone" if options[:standalone]

        if type == "standalone"
          template "standalone_action.tt", "app/jav/actions/#{singular_name}.rb"
        else
          template "action.tt", "app/jav/actions/#{singular_name}.rb"
        end
      end
    end
  end
end
