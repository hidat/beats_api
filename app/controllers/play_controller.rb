class PlayController < ApplicationController

  def index
    @client_id = Rails.application.secrets.beats_client_id
    @user_id = Rails.application.secrets.beats_user_id
    @access_token = params[:access_token]
  end
end
