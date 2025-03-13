# frozen_string_literal: true

module Mutations
  class DeleteNote < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      note = Note.find_by(id: id)
      return { success: false, errors: [ "Note not found" ] } unless note

      if note.destroy!
        { success: true, errors: [] }
      else
        { success: false, errors: note.errors.full_messages }
      end
    end
  end
end
