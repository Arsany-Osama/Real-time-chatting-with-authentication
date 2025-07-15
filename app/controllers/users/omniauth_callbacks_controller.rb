class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    Rails.logger.debug("Session before auth: #{session.inspect}")
    Rails.logger.debug("OmniAuth Auth: #{request.env['omniauth.auth'].inspect}")
    Rails.logger.debug("State from params: #{request.env['omniauth.params']&.dig('state')}")
    Rails.logger.debug("Session state: #{session[:'omniauth.state']}")
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # This will set the user in the session
      set_flash_message :notice, 'Successfully authenticated via Google.' if is_navigational_format?
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_path, alert: 'Authentication failed.'
    end
  rescue StandardError => e
    Rails.logger.error("OmniAuth Error: #{e.message}")
    redirect_to new_user_registration_path, alert: "Authentication error: #{e.message}"
  end

  def failure
    Rails.logger.error("OmniAuth Failure: #{failure_message}")
    Rails.logger.debug("Session on failure: #{session.inspect}")
    redirect_to new_user_registration_path, alert: "Authentication failed: #{failure_message}"
  end
end
