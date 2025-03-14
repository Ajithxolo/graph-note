require 'rails_helper'

RSpec.describe OpenAiClient, type: :service, vcr: { cassette_name: "open_ai_client_chat_completion" } do
  let(:api_key) { Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY'] || "test_api_key" }
  subject(:client) { described_class.new(api_key) }

  describe '#chat_completion' do
    context 'when the API key is valid' do
      let(:messages) {
        [
          { role: "system", content: "Analyze sentiment: positive, negative, or neutral. Return a sentiment score between -1.0 and 1.0." },
          { role: "user", content: "I love this product!" }
        ]
      }

      it 'return a parsed response with choices' do
        response = client.chat_completion(messages: messages)
        expect(response).to be_a(Hash)
        expect(response).to have_key("choices")
      end
    end
  end
end
