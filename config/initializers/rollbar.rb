require 'rollbar/rails'

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']

  # Here we'll disable in test and dev, since it enables in all environments by
  # default
  if !Rails.env.production?
    config.enabled = false
  end

  config.environment = ENV["APP_ENVIRONMENT"] || "development"

  config.exception_level_filters.merge!({
    'ActionController::RoutingError' => 'ignore',
    'ActionController::UnknownHttpMethod' => 'ignore',
    'ActionController::BadRequest' => 'ignore',
    'ActionView::MissingTemplate' => 'ignore'
  })

  config.scrub_fields |= [
    '_session_id',
    'access_token',
    'authenticity_token',
    'oauth_grant.code',
    'oauth_token',
    'password',
    'refresh_token',
    'request.session',
    'session'
  ]
  config.scrub_headers |= [
    'Authorization',
    'Cookies',
    'HTTP_AUTHORIZATION',
    'HTTP_X_CSRF_TOKEN',
    'X_CSRF_TOKEN',
  ]
  config.use_sucker_punch
end
