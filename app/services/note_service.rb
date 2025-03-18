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

  def self.update_note(attributes)
    note = Note.find_by(id: attributes[:id])
    return Result.new(false, nil, [ "Note not found" ]) unless note

    note.title = attributes[:title] if attributes[:title].present?
    new_body = attributes[:body].presence

    if new_body && new_body != note.body
      begin
        sentiment = SentimentAnalysisService.new.analyze(new_body)
        if sentiment[:error]
          return Result.new(false, nil, [ sentiment[:error] ], sentiment[:error])
        end

        note.assign_attributes(
          body: new_body,
          sentiment_score: sentiment[:sentiment_score],
          sentiment_label: sentiment[:sentiment_label]
        )
      rescue StandardError => e
        return Result.new(false, nil, [ e.message ], e.message)
      end
    end

    if note.save
      Result.new(true, note, [])
    else
      Result.new(false, nil, note.errors.full_messages)
    end
  end

  def self.delete_note(attributes)
    note = Note.find_by(id: attributes[:id])
    if note
      note.destroy
      { success: true, errors: [] }
    else
      { success: false, errors: [ "Note not found" ] }
    end
  end
end
