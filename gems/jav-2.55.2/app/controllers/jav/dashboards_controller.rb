require_dependency "jav/application_controller"

module Jav
  class DashboardsController < ApplicationController
    before_action :set_dashboard, only: :show

    def show
      @page_title = @dashboard.name
    end

    private

    def set_dashboard
      @dashboard = Jav::App.get_dashboard_by_id params[:id]

      authorized = Jav::Hosts::BaseHost.new(block: @dashboard.authorize).handle
      raise Jav::NotAuthorizedError, "Not Authorized" unless authorized

      raise ActionController::RoutingError, "Not Found" if @dashboard.nil? || @dashboard.is_hidden?
    end
  end
end
