class Note < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks unless Rails.env.test?
  validates :title, :body, :sentiment_score, :sentiment_label, presence: true
end
