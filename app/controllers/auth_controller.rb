class AuthController < ApplicationController
  def beats_callback
    access_token = params[:access_token]
    state = params[:state]
    token_type = params[:token_type]
    expires = params[:expires]
    redirect_to(controller: 'play', action: 'index', access_token: access_token)
  end
end
