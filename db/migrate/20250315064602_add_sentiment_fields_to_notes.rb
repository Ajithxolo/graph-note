class AddSentimentFieldsToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :sentiment_score, :float, default: 0.0, null: false
    add_column :notes, :sentiment_label, :string, default: 'neutral', null: false
  end
end
