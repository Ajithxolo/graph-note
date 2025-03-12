# frozen_string_literal: true

module Mutations
  class CreateNote < BaseMutation
    field :note, Types::NoteType, null: true
    field :errors, [ String ], null: false

    argument :title, String, required: true
    argument :body, String, required: true

    def resolve(title:, body:)
      note = Note.new(title: title, body: body)

      if note.save
        { note: note, errors: [] }
      else
        { note: nil, errors: note.errors.full_messages }
      end
    end
  end
end
