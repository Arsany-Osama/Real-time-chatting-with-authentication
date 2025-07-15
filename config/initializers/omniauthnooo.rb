# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :google_oauth2,
#            ENV['GOOGLE_CLIENT_ID'],
#            ENV['GOOGLE_CLIENT_SECRET'],
#            scope: 'userinfo.email,userinfo.profile',
#            prompt: 'select_account',
#            access_type: 'offline'
#   on_failure do |env|
#     Rails.logger.error("OmniAuth Failure: #{env['omniauth.error'].inspect}")
#     [302, { 'Location' => '/users/sign_in', 'Content-Type' => 'text/html' }, ['Redirecting to sign in...']]
#   end
# end

# # Temporary patch to bypass CSRF state validation
# module OmniAuth
#   module Strategies
#     class GoogleOauth2 < OAuth2
#       def callback_phase
#         super
#       rescue ::OmniAuth::Strategies::OAuth2::CallbackError
#         fail!(:invalid_state, $!)
#         return redirect('/users/sign_in')
#       end
#     end
#   end
# end
