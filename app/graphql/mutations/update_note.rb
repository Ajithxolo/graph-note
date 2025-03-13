# frozen_string_literal: true

module Mutations
  class UpdateNote < BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false

    field :note, Types::NoteType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, title: nil, body: nil)
      note = Note.find_by(id: id)
      return { note: nil, errors: [ "Note not found" ] } unless note

      if note.update(title: title, body: body)
        { note: note, errors: [] }
      else
        { note: nil, errors: note.errors.full_messages }
      end
    end
  end
end
