require_relative "../base_generator"

module Generators
  module Jav
    module Js
      class InstallGenerator < BaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "jav:js:install"
        desc "Add custom JavaScript assets to your Jav project."

        # possible values: importmap or esbuild
        class_option :bundler, type: :string, default: "importmap"

        def create_files
          case options[:bundler].to_s
          when "importmap"
            install_for_importmap
          when "esbuild"
            install_for_esbuild
          else
            say "We don't know how to install Jav JS for this bundler \"#{options[:bundler]}\""
          end
        end

        no_tasks do
          def install_for_importmap
            unless Rails.root.join("app/javascript/jav.custom.js").exist?
              say "Add default app/javascript/jav.custom.js"
              copy_file template_path("jav.custom.js"), "app/javascript/jav.custom.js"
            end

            say "Ejecting the _head.html.erb partial"
            Rails::Generators.invoke("jav:eject", [":head", "--skip-jav-version"], { destination_root: Rails.root })

            say "Adding the JS asset to the partial"
            append_to_file Rails.root.join("app/views/jav/partials/_head.html.erb"), "<%= javascript_importmap_tags \"jav.custom\" %>"

            # pin to importmap
            say "Pin the new entrypoint to your importmap config"
            append_to_file Rails.root.join("config/importmap.rb"), "\n# Jav custom JS entrypoint\npin \"jav.custom\", preload: true\n"
          end

          def install_for_esbuild
            unless Rails.root.join("app/javascript/jav.custom.js").exist?
              say "Add default app/javascript/jav.custom.js"
              copy_file template_path("jav.custom.js"), "app/javascript/jav.custom.js"
            end

            say "Ejecting the _head.html.erb partial"
            Rails::Generators.invoke("jav:eject", [":head", "--skip-jav-version"], { destination_root: Rails.root })

            say "Adding the JS asset to the partial"
            append_to_file Rails.root.join("app/views/jav/partials/_head.html.erb"), "<%= javascript_include_tag \"jav.custom\", \"data-turbo-track\": \"reload\", defer: true %>"
          end

          def template_path(filename)
            Pathname.new(__dir__).join("..", "templates", "js", filename).to_s
          end
        end
      end
    end
  end
end
