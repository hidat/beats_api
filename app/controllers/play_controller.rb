class PlayController < ApplicationController

  def index
    @track_id = params[:track_id]
    @client_id = Rails.application.secrets.beats_client_id
    @access_token = params[:access_token]
  end
end
