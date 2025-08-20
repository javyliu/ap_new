require 'fileutils'
require_relative 'base_generator'

module Generators
  module Jav
    class ToolGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)

      argument :name, type: :string, required: true

      namespace 'jav:tool'

      def handle
        # Sidebar items
        template 'tool/sidebar_item.tt', "app/views/jav/sidebar/items/_#{file_name}.html.erb"

        # Add controller if it doesn't exist
        controller_path = 'app/controllers/jav/tools_controller.rb'
        template 'tool/controller.tt', controller_path unless File.file?(Rails.root.join(controller_path))

        # Add controller method
        inject_into_class controller_path, 'Jav::ToolsController' do
          <<-METHOD
  def #{file_name}
    @page_title = "#{human_name}"
    add_breadcrumb "#{human_name}"
  end
          METHOD
        end

        # Add view file
        template 'tool/view.tt', "app/views/jav/tools/#{file_name}.html.erb"

        if ::Jav.configuration.root_path == ''
          route <<-ROUTE
  get "#{file_name}", to: "jav/tools##{file_name}"
          ROUTE
        else
          route <<~ROUTE
            scope :#{::Jav.configuration.namespace} do
              get "#{file_name}", to: "jav/tools##{file_name}"
            end
          ROUTE
        end
      end

      no_tasks do
        def file_name
          name.to_s.underscore
        end

        def controller_name
          file_name.to_s
        end

        def human_name
          file_name.humanize
        end

        def in_code(text)
          "<code class='p-1 rounded-sm bg-gray-500 text-white text-sm'>#{text}</code>"
        end
      end
    end
  end
end
