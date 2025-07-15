# frozen_string_literal: true

   Devise.setup do |config|
     config.omniauth_path_prefix = '/users/auth'
     config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
     require 'devise/orm/active_record'
     config.case_insensitive_keys = [:email]
     config.strip_whitespace_keys = [:email]
     config.skip_session_storage = [:http_auth]
     config.stretches = Rails.env.test? ? 1 : 12 #bcrypt 1 time in testing mode
     config.reconfirmable = true # if true, user will be asked to confirm email after changing it
     config.password_length = 6..128 # minimum and maximum length of password
     config.email_regexp = /\A[^@\s]+@[^@\s]+\z/ # regexp for email validation
     config.reset_password_within = 2.hours # time period for reset password token validity
     config.sign_out_via = :delete # HTTP method for sign out
     config.omniauth :google_oauth2,
                     ENV['GOOGLE_CLIENT_ID'],
                     ENV['GOOGLE_CLIENT_SECRET'],
                     scope: 'userinfo.email,userinfo.profile', # scope of access to user information
                     prompt: 'select_account',
                     access_type: 'offline' # to send refresh token besides access token
   end
