class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :pid           # id original del post o tweet
      t.string :friend        # id de amigo en la base de datos
      t.string :post_type
      t.text :text
      t.datetime :created_at
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
