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

ActiveRecord::Schema[8.1].define(version: 2025_12_09_074318) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "festivals", force: :cascade do |t|
    t.string "address"
    t.integer "capacity", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at"
    t.string "meeting_place_name", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.text "participation_conditions"
    t.string "prefecture", null: false
    t.boolean "published", default: false, null: false
    t.datetime "start_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_festivals_on_organization_id"
  end

  create_table "organization_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "organizer_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["organizer_id", "organization_id"], name: "index_organization_memberships_on_organizer_and_organization", unique: true
    t.index ["organizer_id"], name: "index_organization_memberships_on_organizer_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "address"
    t.string "city", null: false
    t.string "contact_email", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "phone", null: false
    t.string "prefecture", null: false
    t.bigint "primary_owner_id", null: false
    t.string "sns_url"
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["primary_owner_id"], name: "index_organizations_on_primary_owner_id"
  end

  create_table "organizers", force: :cascade do |t|
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_organizers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_organizers_on_reset_password_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "festivals", "organizations"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "organizers"
  add_foreign_key "organizations", "organizers", column: "primary_owner_id"
end
