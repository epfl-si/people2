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

ActiveRecord::Schema[8.0].define(version: 2028_06_25_123221) do
  create_table "accreds", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id"
    t.integer "unit_id"
    t.integer "position", null: false
    t.string "sciper"
    t.integer "visibility", default: 0
    t.integer "address_visibility", default: 0
    t.string "unit_fr"
    t.string "unit_en"
    t.string "unit_it"
    t.string "unit_de"
    t.text "role", null: false
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "position"], name: "index_accreds_on_profile_id_and_position", unique: true
    t.index ["profile_id"], name: "index_accreds_on_profile_id"
  end

  create_table "achievements", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "position", null: false
    t.bigint "profile_id", null: false
    t.bigint "category_id", null: false
    t.integer "year", null: false
    t.text "description_en"
    t.text "description_fr"
    t.text "description_it"
    t.text "description_de"
    t.string "url"
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_achievements_on_category_id"
    t.index ["profile_id"], name: "index_achievements_on_profile_id"
  end

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
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

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "adoptions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper"
    t.string "email"
    t.string "dn"
    t.string "fullname"
    t.boolean "with_legacy_profile", default: false
    t.boolean "accepted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_adoption_on_email"
    t.index ["sciper"], name: "unique_scipers", unique: true
  end

  create_table "artists", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "awards", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "category_id", null: false
    t.bigint "origin_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "issuer"
    t.integer "year"
    t.string "url"
    t.integer "position", null: false
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_awards_on_category_id"
    t.index ["origin_id"], name: "index_awards_on_origin_id"
    t.index ["profile_id", "position"], name: "index_awards_on_profile_id_and_position", unique: true
    t.index ["profile_id"], name: "index_awards_on_profile_id"
  end

  create_table "boxes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "subkind"
    t.bigint "profile_id", null: false
    t.bigint "section_id", null: false
    t.bigint "model_box_id"
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.boolean "show_title", default: true
    t.boolean "locked_title", default: false
    t.integer "visibility", default: 0
    t.integer "position", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_box_id"], name: "index_boxes_on_model_box_id"
    t.index ["profile_id"], name: "index_boxes_on_profile_id"
    t.index ["section_id"], name: "index_boxes_on_section_id"
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "code"
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "language_en"
    t.string "language_fr"
    t.string "language_it"
    t.string "language_de"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "educations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "field_en"
    t.string "field_fr"
    t.string "field_it"
    t.string "field_de"
    t.string "director"
    t.string "school", null: false
    t.integer "year_begin"
    t.integer "year_end"
    t.integer "position", null: false
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "position"], name: "index_educations_on_profile_id_and_position", unique: true
    t.index ["profile_id"], name: "index_educations_on_profile_id"
  end

  create_table "experiences", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "location"
    t.integer "year_begin", null: false
    t.integer "year_end"
    t.integer "position", null: false
    t.integer "visibility", default: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "position"], name: "index_experiences_on_profile_id_and_position", unique: true
    t.index ["profile_id"], name: "index_experiences_on_profile_id"
  end

  create_table "function_changes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "accreditation_id"
    t.string "requested_by"
    t.string "treated_by"
    t.text "accreditor_scipers"
    t.string "status"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "function_en"
    t.string "function_fr"
    t.string "function_it"
    t.string "function_de"
  end

  create_table "infosciences", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "url"
    t.integer "position"
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_infosciences_on_profile_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "image_url"
    t.bigint "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_items_on_artist_id"
  end

  create_table "model_boxes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "kind", default: "RichTextBox"
    t.string "subkind"
    t.integer "max_copies", default: 1
    t.bigint "section_id", null: false
    t.string "label", null: false
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "description_en"
    t.string "description_fr"
    t.string "description_it"
    t.string "description_de"
    t.boolean "standard", default: true
    t.boolean "show_title", default: true
    t.boolean "locked_title", default: true
    t.integer "position", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_model_boxes_on_label", unique: true
    t.index ["section_id"], name: "index_model_boxes_on_section_id"
  end

  create_table "motds", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "level", default: "info"
    t.date "expiration"
    t.boolean "public"
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_motds_on_category_id"
  end

  create_table "name_change_requests", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "old_first"
    t.string "old_last"
    t.string "new_first"
    t.string "new_last"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_name_change_requests_on_profile_id"
  end

  create_table "pictures", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.integer "failed_attempts", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source"
    t.index ["profile_id"], name: "index_pictures_on_profile_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper"
    t.integer "birthday_visibility", default: 4
    t.integer "nationality_visibility", default: 4
    t.integer "personal_phone_visibility", default: 4
    t.integer "photo_visibility", default: 4
    t.integer "personal_web_url_visibility", default: 4
    t.integer "expertise_visibility", default: 0
    t.integer "phone_visibility", default: 0
    t.string "personal_web_url"
    t.string "personal_phone"
    t.string "expertise_en"
    t.string "expertise_fr"
    t.string "expertise_it"
    t.string "expertise_de"
    t.string "nationality_en"
    t.string "nationality_fr"
    t.string "nationality_it"
    t.string "nationality_de"
    t.boolean "en_enabled", default: true
    t.boolean "fr_enabled", default: true
    t.boolean "it_enabled", default: false
    t.boolean "de_enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "selected_picture_id"
    t.bigint "camipro_picture_id"
    t.boolean "inclusivity", default: false, null: false
    t.index ["camipro_picture_id"], name: "index_profiles_on_camipro_picture_id"
    t.index ["sciper"], name: "unique_scipers", unique: true
    t.index ["selected_picture_id"], name: "index_profiles_on_selected_picture_id"
  end

  create_table "publications", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.text "title", null: false
    t.string "url"
    t.text "authors", null: false
    t.integer "year"
    t.integer "position", null: false
    t.string "journal", null: false
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_publications_on_profile_id"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "label"
    t.string "zone", default: "main"
    t.string "edit_zone", default: "main"
    t.integer "position", null: false
    t.boolean "show_title"
    t.boolean "create_allowed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "selectable_properties", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "label"
    t.string "name_en"
    t.string "name_fr"
    t.string "name_it"
    t.string "name_de"
    t.string "property", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "socials", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "profile_id"
    t.string "tag"
    t.string "value"
    t.integer "position", default: 0
    t.integer "visibility", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_socials_on_profile_id"
  end

  create_table "special_options", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper"
    t.string "ns"
    t.string "type", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "structures", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "owners"
    t.string "label"
    t.string "description"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teacherships", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
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

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "provider"
    t.string "sciper"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sciper"], name: "index_users_on_sciper", unique: true
  end

  create_table "usual_name_changes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "official_first", null: false
    t.string "official_last", null: false
    t.string "old_first"
    t.string "old_last"
    t.string "new_first"
    t.string "new_last"
    t.bigint "profile_id", null: false
    t.boolean "done", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_usual_name_changes_on_profile_id"
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

  add_foreign_key "achievements", "profiles"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "awards", "profiles"
  add_foreign_key "awards", "selectable_properties", column: "category_id"
  add_foreign_key "awards", "selectable_properties", column: "origin_id"
  add_foreign_key "boxes", "model_boxes"
  add_foreign_key "boxes", "profiles"
  add_foreign_key "boxes", "sections"
  add_foreign_key "educations", "profiles"
  add_foreign_key "experiences", "profiles"
  add_foreign_key "infosciences", "profiles"
  add_foreign_key "items", "artists"
  add_foreign_key "model_boxes", "sections"
  add_foreign_key "name_change_requests", "profiles"
  add_foreign_key "pictures", "profiles"
  add_foreign_key "publications", "profiles"
  add_foreign_key "sessions", "users"
  add_foreign_key "teacherships", "courses"
  add_foreign_key "teacherships", "profiles"
  add_foreign_key "usual_name_changes", "profiles"
end
