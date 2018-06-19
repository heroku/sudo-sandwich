require 'sinatra/base'

class FakePlatformApi < Sinatra::Base
  post '/addons/:heroku_uuid/actions/provision' do
    json_response 200, 'provision_plan_response.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
