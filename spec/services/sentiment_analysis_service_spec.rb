require 'rails_helper'

RSpec.describe SentimentAnalysisService, type: :service do
  describe '#analyze' do
    context 'when a valid text is passed' do
      let(:positive_text) { "I absolutely love this app, it's amazing!" }
      let(:negative_text) { "I absolutely hate this app, it's terrible!" }
      let(:neutral_text) { "This app is okay, neither great nor bad." }

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

      it 'returns a sentiment score and label for neutral sentiment', vcr: { cassette_name: "sentiment_analysis_neutral" } do
        response = SentimentAnalysisService.new.analyze(neutral_text)
        expect(response[:sentiment_score]).to eq(0.0)
        expect(response[:sentiment_label]).to eq('neutral')
      end
    end

    context 'when an invalid text is passed' do
      let(:invalid_text) { nil }

      it 'returns an error response for nil text' do
        response = SentimentAnalysisService.new.analyze(invalid_text)
        expect(response).to include(:error)
        expect(response[:error]).to eq('Text must be present.')
      end
    end
  end
end
