# frozen_string_literal: true

module Mutations
  class UpdateNote < BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false

    field :note, Types::NoteType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, title: nil, body: nil)
      result = NoteService.update_note(id: id, title: title, body: body)
      return { note: nil, errors: [ "Note not found" ] } unless result

      if result.success?
        { note: result&.note, errors: [] }
      else
        { note: nil, errors: result.errors }
      end
    end
  end
end
