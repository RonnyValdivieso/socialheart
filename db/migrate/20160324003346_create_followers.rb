class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.bigint :fid
      t.string :name
      t.string :screen_name
      t.string :location
      t.boolean :following
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
