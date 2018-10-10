class UsageReporter
  BASE_URL = 'https://addons-staging.herokuapp.com'

  def run
    report_usage_data
    mark_usages_as_reported
  end

  private

  attr_reader :response

  def report_usage_data
    @response ||= Excon.new(BASE_URL).post(
      path: "/api/v3/addons/#{slug}/usage_batches",
      headers: {
        'Accept' => 'application/json',
        'Authorization' => basic_auth_token,
        'Content-Type' => 'application/json',
      },
      body: JSON.dump(
        timestamp: formatted_timestamp,
        usages: usages_json
      ),
      expects: 200..299
    )
  end

  def mark_usages_as_reported
    if usage_responses
      usage_responses.each do |usage_json|
        usage_record = usage_for(usage_json)

        if usage_record && usage_json["status"] == "accepted"
          usage_record.update!(reported: true)
        elsif usage_record # rejected
          usage_record.update!(error_messages: usage_json["errors"])
        end
      end
    else
      puts response.body
    end
  end

  def usage_for(usage_json)
    Usage.
      joins(:sandwich).
      where(sandwiches: { heroku_uuid: usage_json["resource"]["id"] }).
      where(quantity: usage_json["quantity"]).
      where(unit: usage_json["unit"]["name"]).
      find_by(timestamp: timestamp)
  end

  def usage_responses
    response_body['usages']
  end

  def timestamp
    @_timestamp ||= response_body['timestamp']
  end

  def response_body
    @_response_body ||= JSON.parse(response.body)
  end

  def formatted_timestamp
    (Time.current.beginning_of_hour - 1.hour).
      strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def usages_json
    usages_for_previous_hour.map do |usage|
      {
        quantity: usage.quantity,
        resource: { id: usage.sandwich.heroku_uuid },
        unit: { name: usage.unit }
      }
    end
  end

  def usages_for_previous_hour
    Usage.
      includes(:sandwich).
      where("timestamp = ?", 1.hour.ago.beginning_of_hour)
  end

  def basic_auth_token
    ActionController::HttpAuthentication::Basic.encode_credentials(slug, password)
  end

  def slug
    ENV['SLUG']
  end

  def password
    ENV['PASSWORD']
  end
end
