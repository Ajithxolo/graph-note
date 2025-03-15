require 'rails_helper'

RSpec.describe NoteService, type: :service do
  describe '#create_note' do
    subject(:result) { NoteService.create_note(attributes) }

    context 'when valid attributes passed' do
      let(:attributes) { { title: 'Test Note', body: 'This is a positive note.' } }
      let(:sentiment_result) { { sentiment_score: 1.0, sentiment_label: 'positive' } }

      before do
        expect_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .with(attributes[:body])
          .and_return(sentiment_result)
      end

      it 'creates a note with sentiment analysis results' do
        expect(result.success?).to be true
        note = result.note
        expect(note).to be_persisted
        expect(note.title).to eq('Test Note')
        expect(note.body).to eq('This is a positive note.')
        expect(note.sentiment_score).to eq(1.0)
        expect(note.sentiment_label).to eq('positive')
      end
    end
  end
end
