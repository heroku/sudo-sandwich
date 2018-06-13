require "sinatra/base"

class FakeCoreIdentityApi < Sinatra::Base
  post "/oauth/token" do
    json_response 200, "grant_code_exchange_response.json"
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
