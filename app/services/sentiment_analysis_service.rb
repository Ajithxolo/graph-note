require "httparty"

class SentimentAnalysisService
  OPENAI_URL = "https://api.openai.com/v1/chat/completions"

  def initialize(api_key = Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"])
    @api_key = api_key
  end

  def analyze(text)
    begin
      response = call_openai_api(text)
      parsed_response = parse_response(response)
      parsed_response
    rescue StandardError => e
      { error: e.message }
    end
  end

  private

  def call_openai_api(text)
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{@api_key}"
    }

    body = {
      model: "gpt-4",
      messages: [ { role: "system", content: "Analyze sentiment: positive, negative, or neutral. Return a sentiment score between -1.0 and 1.0." },
                 { role: "user", content: text } ]
    }.to_json

    response = HTTParty.post(OPENAI_URL, headers: headers, body: body)
    response.parsed_response
  end

  def parse_response(response)
    text_response = response.dig("choices", 0, "message", "content")
    if text_response =~ /positive/i
      { sentiment_score: 1.0, sentiment_label: "positive" }
    elsif text_response =~ /negative/i
      { sentiment_score: -1.0, sentiment_label: "negative" }
    else
      { sentiment_score: 0.0, sentiment_label: "neutral" }
    end
  end
end
