class Note < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks unless Rails.env.test?
  validates :title, :body, :sentiment_score, :sentiment_label, presence: true
  
  def self.search_by_keyword(keyword)
    response = __elasticsearch__.search(
      query: {
        multi_match: {
          query: keyword,
          fields: ['title^2', 'body']
        }
      }
    )
    response.records.to_a
  end
end
