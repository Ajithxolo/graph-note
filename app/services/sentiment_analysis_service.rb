require "httparty"

class SentimentAnalysisService
  def initialize(client: OpenAiClient.new)
    @client = client
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
    messages = [
      { role: "system", content: "Analyze sentiment: positive, negative, or neutral. Return a sentiment score between -1.0 and 1.0." },
      { role: "user", content: text }
    ]
    @client.chat_completion(messages: messages)
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
