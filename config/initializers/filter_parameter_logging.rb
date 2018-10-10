# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  '_session',
  'access_token',
  'oauth_grant.code',
  'refresh_token',
  'request.session',
  :access_token,
  :authenticity_token,
  :oauth_token,
  :password,
  :session
]
