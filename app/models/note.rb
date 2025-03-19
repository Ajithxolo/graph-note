class Note < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  validates :title, :body, :sentiment_score, :sentiment_label, presence: true
end
