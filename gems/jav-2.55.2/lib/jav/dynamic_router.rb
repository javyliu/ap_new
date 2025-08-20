module Jav
  class DynamicRouter
    def self.routes
      Jav::Engine.routes.draw do
        scope "resources", as: "resources" do
          # Check if the user chose to manually register the resource files.
          # If so, eager_load the resources dir.

          Jav::App.eager_load(:resources) if Jav.configuration.resources.nil? && !Rails.application.config.eager_load

          Jav::App.fetch_resources
                  .reject { |resource| resource == :BaseResource }
                  .select { |resource| resource.is_a? Class }
                  .map { |resource| resources resource.new.route_key }
        end
      end
    end
  end
end
