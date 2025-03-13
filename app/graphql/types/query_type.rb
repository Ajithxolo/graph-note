# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :fetch_notes, [ Types::NoteType ], null: false, description: "Fetch all notes"

    def fetch_notes
      Note.all
    end
  end
end
