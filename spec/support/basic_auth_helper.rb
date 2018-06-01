module BasicAuthHelper
  def http_login(username, password)
    @request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
