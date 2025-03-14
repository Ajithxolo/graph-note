require 'rails_helper'

RSpec.describe SentimentAnalysisService, type: :service do
  describe '#analyze' do
    context 'when a valid text is passed' do
      let(:positive_text) { "I absolutely love this app, it's amazing!" }
      let(:negative_text) { "I absolutely hate this app, it's terrible!" }
      it 'returns a sentiment score and label for positive sentiment', vcr: { cassette_name: "sentiment_analysis_positive" } do
        response = SentimentAnalysisService.new.analyze(positive_text)
        expect(response).to include(:sentiment_score, :sentiment_label)
        expect(response[:sentiment_score]).to be_a(Float)
        expect(response[:sentiment_score]).to eq(1.0)
        expect(response[:sentiment_label]).to eq('positive')
      end

      it 'returns a sentiment score and label for negative sentiment', vcr: { cassette_name: "sentiment_analysis_negative" } do
        response = SentimentAnalysisService.new.analyze(negative_text)
        expect(response).to include(:sentiment_score, :sentiment_label)
        expect(response[:sentiment_score]).to be_a(Float)
        expect(response[:sentiment_score]).to eq(-1.0)
        expect(response[:sentiment_label]).to eq('negative')
      end
    end
  end
end
