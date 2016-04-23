class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :tid
      t.string :friend
      t.string :tweet_type
      t.string :text
      t.datetime :created_at
      t.string :geo
      t.string :place
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
