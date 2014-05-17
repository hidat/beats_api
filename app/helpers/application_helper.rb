module ApplicationHelper

  def beats_auth_url
    qp = {
        state: 'test',
        response_type: 'token',
        redirect_url: 'http://127.0.0.1:3000/auth/beats_callback',
        client_id: Rails.application.secrets.beats_client_id
    }
    "https://partner.api.beatsmusic.com/v1/oauth2/authorize?" + qp.to_query()
  end

end
