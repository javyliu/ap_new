require_dependency "jav/application_controller"

module Jav
  class DebugController < ApplicationController
    def index; end

    def report; end

    def refresh_license
      license = Licensing::LicenseManager.refresh_license request

      if license.valid?
        flash[:notice] = "javhq.io responded: \"#{license.id.humanize} license is valid\"."
      elsif license.response['reason'].present?
        flash[:error] = "javhq.io responded: \"#{license.response['reason']}\"."
      else
        flash[:error] = license.response['error']
      end

      redirect_back fallback_location: jav.jav_private_debug_index_path
    end
  end
end
