require_dependency "jav/application_controller"

module Jav
  class HomeController < ApplicationController
    def index
      if Jav.configuration.home_path.present?
        # If the home_path is a block run it, if not, just use it
        computed_path = if Jav.configuration.home_path.respond_to? :call
                          instance_exec(&Jav.configuration.home_path)
                        else
                          Jav.configuration.home_path
                        end

        redirect_to computed_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        resource = Jav::App.resources.min_by(&:model_key)
        redirect_to resources_path(resource: resource)
      end
    end

    def failed_to_load; end
  end
end
