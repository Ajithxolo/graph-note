require 'rails_helper'

RSpec.describe SentimentAnalysisService, type: :service, vcr: { cassette_name: "sentiment_analysis" } do
  describe '#analyze' do
    context 'when a valid text is passed' do
      let(:sample_text) { "I absolutely love this app, it's amazing!" }

      it 'returns a sentiment score and label' do
        response = SentimentAnalysisService.new.analyze(sample_text)

        expect(response).to include(:sentiment_score, :sentiment_label)
        expect(response[:sentiment_score]).to be_a(Float)
        expect(response[:sentiment_label]).to be_in([ 'positive', 'negative', 'neutral' ])
      end
    end
  end
end
