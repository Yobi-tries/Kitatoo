# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_25_101700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "artist_profile_id", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "label"
    t.float "latitude"
    t.float "longitude"
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.string "zipcode", null: false
    t.index ["artist_profile_id"], name: "index_addresses_on_artist_profile_id"
  end

  create_table "artist_profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.text "pricing_grid"
    t.string "professional_status"
    t.boolean "published", default: false, null: false
    t.text "social_links"
    t.string "styles"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_artist_profiles_on_user_id", unique: true
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.bigint "artist_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "starts_at", null: false
    t.integer "state", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_availabilities_on_address_id"
    t.index ["artist_profile_id"], name: "index_availabilities_on_artist_profile_id"
    t.index ["starts_at"], name: "index_availabilities_on_starts_at"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "availability_id", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["availability_id"], name: "index_bookings_on_availability_id", unique: true
    t.index ["client_id"], name: "index_bookings_on_client_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "artist_profile_id", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_profile_id"], name: "index_conversations_on_artist_profile_id"
    t.index ["client_id", "artist_profile_id"], name: "index_conversations_on_client_and_artist", unique: true
    t.index ["client_id"], name: "index_conversations_on_client_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "portfolio_items", force: :cascade do |t|
    t.bigint "artist_profile_id", null: false
    t.string "caption"
    t.datetime "created_at", null: false
    t.string "image_url", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["artist_profile_id"], name: "index_portfolio_items_on_artist_profile_id"
  end

  create_table "tattoo_generations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "image_url"
    t.text "prompt", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_tattoo_generations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birthdate", null: false
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "addresses", "artist_profiles"
  add_foreign_key "artist_profiles", "users"
  add_foreign_key "availabilities", "addresses"
  add_foreign_key "availabilities", "artist_profiles"
  add_foreign_key "bookings", "availabilities"
  add_foreign_key "bookings", "users", column: "client_id"
  add_foreign_key "conversations", "artist_profiles"
  add_foreign_key "conversations", "users", column: "client_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "portfolio_items", "artist_profiles"
  add_foreign_key "tattoo_generations", "users"
end
