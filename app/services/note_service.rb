# app/services/note_service.rb
class NoteService
  Result = Struct.new(:success?, :note, :errors, :error)

  def self.create_note(attributes)
    begin
      sentiment = SentimentAnalysisService.new.analyze(attributes[:body])

      # If sentiment analysis returns an error, fail early
      if sentiment[:error]
        return Result.new(false, nil, [ sentiment[:error] ], sentiment[:error])
      end

      note = Note.new(
        title: attributes[:title],
        body: attributes[:body],
        sentiment_score: sentiment[:sentiment_score],
        sentiment_label: sentiment[:sentiment_label]
      )

      if note.save
        Result.new(true, note, [])
      else
        Result.new(false, nil, note.errors.full_messages)
      end
    rescue StandardError => e
      Result.new(false, nil, [ e.message ], e.message)
    end
  end
end
