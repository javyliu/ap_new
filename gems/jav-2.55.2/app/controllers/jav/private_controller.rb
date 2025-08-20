require_dependency "jav/application_controller"

module Jav
  class PrivateController < ApplicationController
    def design
      @page_title = "Design [Private]"
    end
  end
end
