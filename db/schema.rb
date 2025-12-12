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

ActiveRecord::Schema[8.1].define(version: 2025_12_11_061808) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "category"
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.bigint "organization_id"
    t.string "service_name", null: false
    t.index ["category", "organization_id"], name: "index_active_storage_blobs_on_category_and_organization_id"
    t.index ["category"], name: "index_active_storage_blobs_on_category"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    t.index ["organization_id"], name: "index_active_storage_blobs_on_organization_id"
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "festival_participations", force: :cascade do |t|
    t.text "cancel_reason"
    t.datetime "checkin_at"
    t.bigint "checkin_by_id"
    t.datetime "created_at", null: false
    t.bigint "festival_id", null: false
    t.text "organizer_memo"
    t.string "payment_status"
    t.string "status"
    t.datetime "updated_at", null: false
    t.text "user_comment"
    t.bigint "user_id", null: false
    t.index ["checkin_by_id"], name: "index_festival_participations_on_checkin_by_id"
    t.index ["festival_id"], name: "index_festival_participations_on_festival_id"
    t.index ["user_id"], name: "index_festival_participations_on_user_id"
  end

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
    t.string "nickname"
    t.string "real_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_blobs", "organizations"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "festival_participations", "festivals"
  add_foreign_key "festival_participations", "organizers", column: "checkin_by_id"
  add_foreign_key "festival_participations", "users"
  add_foreign_key "festivals", "organizations"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "organizers"
  add_foreign_key "organizations", "organizers", column: "primary_owner_id"
end
