class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  attr_reader :device

  private

  def current_user
    device.author if device
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @device = Device.find_by({ device_id: token })
    end
  end

end
