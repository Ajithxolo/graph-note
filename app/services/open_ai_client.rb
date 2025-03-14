class OpenAiClient
  include HTTParty
  OPENAI_URL = "https://api.openai.com/v1"
  def initialize(api_key)
    @api_key = api_key
  end

  def chat_completion(**args)
    messages = args[:messages] || []
    model    = args[:model] || "gpt-4o-mini"
    response = self.class.post(OPENAI_URL + "/chat/completions",
      headers: {
        "Content-Type"  => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      },
      body: { model: model, messages: messages, store: true }.to_json
    )
    response.parsed_response
  end
end
