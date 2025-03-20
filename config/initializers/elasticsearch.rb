# config/initializers/elasticsearch.rb
if defined?(Elasticsearch)
  Elasticsearch::Model.client = Elasticsearch::Client.new(
    url: ENV["ELASTICSEARCH_URL"] || "http://elasticsearch:9200",
    log: true
  )
end
