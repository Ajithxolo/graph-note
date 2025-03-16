# frozen_string_literal: true

module Types
  class NoteType < Types::BaseObject
    field :id, ID, null: false
    field :title, String
    field :body, String
    field :sentiment_score, Float, null: false, method: :sentiment_score
    field :sentiment_label, String, null: false, method: :sentiment_label
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
