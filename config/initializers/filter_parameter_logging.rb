# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  '_session',
  'access_token',
  'oauth_grant.code',
  'refresh_token',
  'request.session',
  'request.session.csrf',
  'request.session.resource.values.access_token_secret',
  'request.session.resource.values.oauth_grant_secret',
  'request.session.resource.values.refresh_token_secret',
  'request.session.resource.values.slow_db_password',
  'request.session.resource.values.slow_db_username',
  :access_token,
  :authenticity_token,
  :oauth_token,
  :password,
  :session
]
