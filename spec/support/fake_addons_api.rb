require 'sinatra/base'

class FakeAddonsApi < Sinatra::Base
  post '/api/v3/addons/:heroku_uuid/usage_batches' do
    json_response 202, "usage_response.json"
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
