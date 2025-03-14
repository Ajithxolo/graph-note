require 'rails_helper'

RSpec.describe OpenAiClient, type: :service, vcr: { cassette_name: "open_ai_client_chat_completion" } do
  let(:api_key) { Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY'] || "test_api_key" }
  subject(:client) { described_class.new(api_key) }
  let(:messages) {
    [
      { role: "system", content: "Analyze sentiment: positive, negative, or neutral. Return a sentiment score between -1.0 and 1.0." },
      { role: "user", content: "I love this product!" }
    ]
  }

  shared_examples 'successful API response' do
    it 'returns a parsed response with choices' do
      response = client.chat_completion(messages: messages)
      expect(response).to be_a(Hash)
      expect(response).to have_key("choices")
    end
  end

  shared_examples 'error API response' do |error_code|
    it 'returns an error response' do
      response = client.chat_completion(messages: messages)
      
      expect(response).to be_a(Hash)
      expect(response).to have_key("error")
      expect(response["error"]["code"]).to eq(error_code)
    end
  end

  describe '#chat_completion' do
    context 'when the API key is valid' do
      it_behaves_like 'successful API response'
    end

    context 'when the API key is invalid' do
      let(:invalid_api_key) { "invalid_api_key" }
      subject(:client) { described_class.new(invalid_api_key) }

      before do
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .with(headers: { "Authorization" => "Bearer #{invalid_api_key}" })
          .to_return(
            status: 401,
            body: {
              error: {
                message: "Incorrect API key provided: #{invalid_api_key}. You can find your API key at https://platform.openai.com/account/api-keys.",
                type: "invalid_request_error",
                code: "invalid_api_key"
              }
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it_behaves_like 'error API response', 'invalid_api_key', "Incorrect API key provided."
    end
  end
end
