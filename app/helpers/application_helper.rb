module ApplicationHelper

  def beats_auth_url
    qp = {
        state: 'test',
        response_type: 'token',
        redirect_url: APP_CONFIG[:auth_callback_url],
        client_id: Rails.application.secrets.beats_client_id
    }
    "https://partner.api.beatsmusic.com/v1/oauth2/authorize?" + qp.to_query()
  end

end
