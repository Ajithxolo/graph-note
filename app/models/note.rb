class Note < ApplicationRecord
  validates :title, :body, :sentiment_score, :sentiment_label, presence: true
end
