# frozen_string_literal: true

module Mutations
  class DeleteNote < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      result = NoteService.delete_note(id: id)
      return { success: false, errors: [ "Note not found" ] } unless result

      result
    end
  end
end
