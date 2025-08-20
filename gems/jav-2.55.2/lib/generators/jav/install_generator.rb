require_relative "base_generator"

module Generators
  module Jav
    class InstallGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "jav:install"
      desc "Creates an Jav initializer adds the route to the routes file."
      class_option :path, type: :string, default: "jav"

      def create_initializer_file
        route "mount Jav::Engine, at: Jav.configuration.root_path"

        template "initializer/jav.tt", "config/initializers/jav.rb"
        create_resources
      end

      def create_resources
        if defined?(User).present?
          Rails::Generators.invoke("jav:resource", ["user", "-q"], {destination_root: Rails.root })
        end

        if defined?(Account).present?
          Rails::Generators.invoke("jav:resource", ["account", "-q"], {destination_root: Rails.root })
        end
      end
    end
  end
end
