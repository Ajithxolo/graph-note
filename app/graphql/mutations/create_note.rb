# frozen_string_literal: true

module Mutations
  class CreateNote < BaseMutation
    field :note, Types::NoteType, null: true
    field :errors, [ String ], null: false

    argument :title, String, required: true
    argument :body, String, required: true

    def resolve(title:, body:)
      result = NoteService.create_note(title: title, body: body)
      if result.success?

        { note: result&.note, errors: [] }
      else
        { note: nil, errors: result.errors }
      end
    end
  end
end
