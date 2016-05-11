# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160504152018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "friend"
    t.string   "activity_type"
    t.integer  "level"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "followers", force: :cascade do |t|
    t.integer  "fid",         limit: 8
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.boolean  "following"
    t.integer  "user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "followers", ["user_id"], name: "index_followers_on_user_id", using: :btree

  create_table "friends", force: :cascade do |t|
    t.string   "fid"
    t.string   "name"
    t.string   "location"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friends", ["user_id"], name: "index_friends_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "pid"
    t.string   "friend"
    t.string   "post_type"
    t.text     "text"
    t.datetime "created_at", null: false
    t.integer  "user_id"
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "uid"
    t.string   "fid"
    t.integer  "level"
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "relationships", ["friend_id"], name: "index_relationships_on_friend_id", using: :btree
  add_index "relationships", ["user_id"], name: "index_relationships_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "screen_name"
    t.string   "email"
    t.binary   "picture"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "oauth_expires_at"
    t.boolean  "first_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_foreign_key "activities", "users"
  add_foreign_key "followers", "users"
  add_foreign_key "friends", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "relationships", "friends"
  add_foreign_key "relationships", "users"
end
