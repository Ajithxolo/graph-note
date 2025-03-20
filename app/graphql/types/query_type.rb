# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :fetch_notes, [ Types::NoteType ], null: false, description: "Fetch all notes"

    def fetch_notes
      Note.all
    end

    field :search_notes, [Types::NoteType], null: false, description: "Search notes by keyword" do
      argument :keyword, String, required: true
    end

    def search_notes(keyword:)
      Note.search_by_keyword(keyword)
    end
  end
end
