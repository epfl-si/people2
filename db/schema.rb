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

ActiveRecord::Schema[7.1].define(version: 2024_03_11_105644) do
  create_table "accred_prefs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id"
    t.integer "unit_id"
    t.integer "order"
    t.string "sciper"
    t.boolean "hidden"
    t.boolean "hidden_addr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_accred_prefs_on_profile_id"
  end

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "artists", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "awards", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "issuer"
    t.integer "year"
    t.integer "audience", default: 0
    t.boolean "visible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_awards_on_profile_id"
  end

  create_table "boxes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "profile_id", null: false
    t.bigint "section_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.boolean "show_title", default: true
    t.boolean "locked", default: false
    t.integer "audience", default: 0
    t.boolean "visible", default: false
    t.integer "position", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_boxes_on_profile_id"
    t.index ["section_id"], name: "index_boxes_on_section_id"
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code"
    t.string "title_en"
    t.string "title_fr"
    t.string "language_en"
    t.string "language_fr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "educations", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "field_en"
    t.string "field_fr"
    t.string "director"
    t.string "school", null: false
    t.integer "year_begin"
    t.integer "year", null: false
    t.integer "audience", default: 0
    t.boolean "visible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_educations_on_profile_id"
  end

  create_table "experiences", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "location"
    t.integer "year_begin", null: false
    t.integer "year_end"
    t.integer "audience", default: 0
    t.boolean "visible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_experiences_on_profile_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "image_url"
    t.bigint "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_items_on_artist_id"
  end

  create_table "model_boxes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "kind", default: "RichTextBox"
    t.bigint "section_id", null: false
    t.string "title_en", null: false
    t.string "title_fr", null: false
    t.boolean "show_title", default: true
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_model_boxes_on_section_id"
  end

  create_table "pictures", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.boolean "camipro", default: false
    t.integer "failed_attempts", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_pictures_on_profile_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "sciper"
    t.boolean "show_birthday"
    t.boolean "show_function"
    t.boolean "show_nationality"
    t.boolean "show_phone"
    t.boolean "show_photo"
    t.boolean "show_title"
    t.boolean "show_weburl"
    t.string "force_lang"
    t.string "personal_web_url"
    t.string "nationality_en"
    t.string "nationality_fr"
    t.string "title_en"
    t.string "title_fr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "selected_picture_id"
    t.bigint "camipro_picture_id"
    t.index ["camipro_picture_id"], name: "index_profiles_on_camipro_picture_id"
    t.index ["sciper"], name: "unique_scipers", unique: true
    t.index ["selected_picture_id"], name: "index_profiles_on_selected_picture_id"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title_en"
    t.string "title_fr"
    t.string "label"
    t.string "zone"
    t.integer "position", null: false
    t.boolean "show_title"
    t.boolean "create_allowed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "socials", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "profile_id"
    t.string "sciper"
    t.string "tag"
    t.string "value"
    t.integer "order", default: 1
    t.boolean "visible", default: true
    t.integer "audience", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_socials_on_profile_id"
  end

  create_table "teacherships", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "profile_id"
    t.string "sciper"
    t.string "role"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_teacherships_on_course_id"
    t.index ["profile_id"], name: "index_teacherships_on_profile_id"
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "awards", "profiles"
  add_foreign_key "boxes", "profiles"
  add_foreign_key "boxes", "sections"
  add_foreign_key "educations", "profiles"
  add_foreign_key "experiences", "profiles"
  add_foreign_key "items", "artists"
  add_foreign_key "model_boxes", "sections"
  add_foreign_key "pictures", "profiles"
  add_foreign_key "teacherships", "courses"
  add_foreign_key "teacherships", "profiles"
end
