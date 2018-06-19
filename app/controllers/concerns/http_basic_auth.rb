module HttpBasicAuth
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  included do
    before_action :http_authenticate
  end

  def http_authenticate
    return true unless Rails.env == 'production'

    authenticate_or_request_with_http_basic do |name, password|
      ActiveSupport::SecurityUtils.secure_compare(name, ENV['SLUG']) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV['PASSWORD'])
    end
  end
end
