require_relative "base_generator"

module Generators
  module Jav
    class LocalesGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "jav:locales"
      desc "Add Jav locale files to your project."

      def create_files
        directory File.join(__dir__, "templates", "locales"), "config/locales"
      end
    end
  end
end
