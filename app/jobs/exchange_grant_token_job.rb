class ExchangeGrantTokenJob < ApplicationJob
  queue_as :default

  def perform(heroku_uuid:, oauth_grant_code:)
    GrantCodeExchanger.new(
      heroku_uuid: heroku_uuid,
      oauth_grant_code: oauth_grant_code,
    ).run
  end
end
