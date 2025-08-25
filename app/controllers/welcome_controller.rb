class WelcomeController < ApplicationController
  allow_unauthenticated_access only: [ :index ]
  # USERS = { "admin" => "helloworld" }

  # before_action :authenticate

  # def index
  #   puts "hello"
  # end


  # private
  #   def authenticate
  #     puts params.inspect
  #     authenticate_or_request_with_http_digest do |username|
  #       USERS[username]
  #     end
  #   end


  # TOKEN = "111secret111"

  # before_action :authenticate

  # private
  #   def authenticate
  #     authenticate_or_request_with_http_token do |token, options|
  #       ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
  #     end
  #   end
end
