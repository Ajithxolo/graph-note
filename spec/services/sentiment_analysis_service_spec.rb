require 'rails_helper'

RSpec.describe SentimentAnalysisService, type: :service do
  subject(:service) { described_class.new }

  describe '#analyze' do
    context 'with valid text input' do
      let(:positive_text) { "I absolutely love this app, it's amazing!" }
      let(:negative_text) { "I absolutely hate this app, it's terrible!" }
      let(:neutral_text)  { "This app is okay, neither great nor bad." }

      context 'when sentiment is positive', vcr: { cassette_name: "sentiment_analysis_positive" } do
        it 'returns a sentiment score of 1.0 and label "positive"' do
          response = service.analyze(positive_text)
          expect(response).to include(:sentiment_score, :sentiment_label)
          expect(response[:sentiment_score]).to eq(1.0)
          expect(response[:sentiment_label]).to eq('positive')
        end
      end

      context 'when sentiment is negative', vcr: { cassette_name: "sentiment_analysis_negative" } do
        it 'returns a sentiment score of -1.0 and label "negative"' do
          response = service.analyze(negative_text)
          expect(response).to include(:sentiment_score, :sentiment_label)
          expect(response[:sentiment_score]).to eq(-1.0)
          expect(response[:sentiment_label]).to eq('negative')
        end
      end

      context 'when sentiment is neutral', vcr: { cassette_name: "sentiment_analysis_neutral" } do
        it 'returns a sentiment score of 0.0 and label "neutral"' do
          response = service.analyze(neutral_text)
          expect(response).to include(:sentiment_score, :sentiment_label)
          expect(response[:sentiment_score]).to eq(0.0)
          expect(response[:sentiment_label]).to eq('neutral')
        end
      end
    end

    context 'with invalid text input' do
      it 'returns an error when nil is passed' do
        response = service.analyze(nil)
        expect(response).to include(:error)
        expect(response[:error]).to eq('Text must be present.')
      end

      it 'returns an error when an empty string is passed' do
        response = service.analyze("   ")
        expect(response).to include(:error)
        expect(response[:error]).to eq('Text must be present.')
      end
    end

    context 'when the API returns an error' do
      let(:sample_text) { "Something unexpected!" }

      it 'handles API errors gracefully' do
        allow_any_instance_of(SentimentAnalysisService)
          .to receive(:call_openai_api)
          .and_raise(StandardError, 'API Error')

        response = service.analyze(sample_text)
        expect(response).to include(:error)
        expect(response[:error]).not_to be_empty
      end
    end

    context 'when sentiment analysis fails' do
      let(:attributes) { { title: 'Test Note', body: 'This is a positive note.' } }

      before do
        allow_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .and_raise(StandardError, 'API error')
      end

      it 'returns an error and does not create a note' do
        result = NoteService.create_note(attributes)
        expect(result.success?).to be false
        expect(result.errors).to include('API error')
      end
    end
  end
end
