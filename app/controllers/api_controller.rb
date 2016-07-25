# class ApiController < ApplicationController
  # include ActionController::HttpAuthentication::Token::ControllerMethods

  # before_action :authenticate

  # def test
    # @values = {}
    # render json: @values.to_json
  # end

  # private

  # def authenticate
    # authenticate_or_request_with_http_token do |token, options|
      # @user = { environment: 'sandbox'} if token == ENV['DP_AUTH']
    # end
  # end
