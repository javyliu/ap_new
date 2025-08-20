require_relative "base_generator"

module Generators
  module Jav
    class EjectGenerator < BaseGenerator
      argument :filename, type: :string, required: true

      source_root ::Jav::Engine.root

      namespace "jav:eject"

      TEMPLATES = {
        logo: "app/views/jav/partials/_logo.html.erb",
        head: "app/views/jav/partials/_head.html.erb",
        header: "app/views/jav/partials/_header.html.erb",
        footer: "app/views/jav/partials/_footer.html.erb",
        pre_head: "app/views/jav/partials/_pre_head.html.erb",
        scripts: "app/views/jav/partials/_scripts.html.erb",
        sidebar_extra: "app/views/jav/partials/_sidebar_extra.html.erb",
        profile_menu_extra: "app/views/jav/partials/_profile_menu_extra.html.erb",
      }

      def handle
        if @filename.starts_with?(":")
          template_id = path_to_sym @filename
          template_path = TEMPLATES[template_id]

          if path_exists? template_path
            eject template_path
          else
            say("Failed to find the `#{template_id.to_sym}` template.", :yellow)
          end
        elsif path_exists? @filename
          eject @filename
        else
          say("Failed to find the `#{@filename}` template.", :yellow)
        end
      end

      no_tasks do
        def path_to_sym(filename)
          template_id = filename.dup
          template_id[0] = ""
          template_id.to_sym
        end

        def path_exists?(path)
          path.present? && File.file?(::Jav::Engine.root.join(path))
        end

        def eject(path)
          copy_file ::Jav::Engine.root.join(path), ::Rails.root.join(path)
        end
      end
    end
  end
end
