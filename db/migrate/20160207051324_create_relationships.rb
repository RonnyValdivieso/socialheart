class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string :uid
      t.string :fid
      t.integer :level
      t.references :user, index: true, foreign_key: true
      t.references :friend, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
