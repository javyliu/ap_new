require_relative "named_base_generator"

module Generators
  module Jav
    class DashboardGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "jav:dashboard"
      desc "Add an Jav dashboard to your project."

      def handle
        template "dashboards/dashboard.tt", "app/jav/dashboards/#{name.underscore}.rb"
      end
    end
  end
end
