class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :screen_name
      t.string :email
      t.binary :picture
      t.string :oauth_token
      t.string :oauth_secret
      t.datetime :oauth_expires_at
      t.boolean :first_time

      t.timestamps null: false
    end
  end
end
