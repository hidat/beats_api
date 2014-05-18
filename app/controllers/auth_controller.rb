class AuthController < ApplicationController
  def beats_callback
    @access_token = params[:access_token]
    @state = params[:state]
    @token_type = params[:token_type]
    @expires = params[:expires]
    @code = params[:code]
    @state = params[:state]
    if @state=='page'
      render('page_auth')
      return
    end
    #redirect_to(controller: 'play', action: 'index', access_token: access_token)
  end
end
