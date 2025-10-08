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

ActiveRecord::Schema[8.0].define(version: 2025_10_08_094859) do
  create_table "admin_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "file"
    t.string "key"
    t.string "en", limit: 1000
    t.string "fr", limit: 1000
    t.string "it", limit: 1000
    t.string "de", limit: 1000
    t.boolean "done", default: false
    t.boolean "auto", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key", "file"], name: "index_admin_translations_on_key_and_file", unique: true
  end

  create_table "ai_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "text_id", null: false
    t.string "ai_model", null: false
    t.float "confidence"
    t.string "lang"
    t.text "content_en", size: :medium
    t.text "content_fr", size: :medium
    t.text "content_it", size: :medium
    t.text "content_de", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text_id"], name: "index_ai_translations_on_text_id"
  end

  create_table "course_instances", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "course_id"
    t.string "acad", limit: 16, null: false
    t.string "slug", limit: 16, null: false
    t.string "level"
    t.string "section"
    t.string "semester"
    t.string "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acad", "slug"], name: "index_course_instances_on_acad_and_slug"
    t.index ["course_id"], name: "index_course_instances_on_course_id"
    t.index ["slug"], name: "index_course_instances_on_slug"
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "acad", limit: 16, null: false
    t.string "slug", limit: 16, null: false
    t.string "slug_prefix", limit: 16, null: false
    t.string "lang", limit: 2
    t.string "title_en"
    t.string "title_fr"
    t.text "description_en"
    t.text "description_fr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fallback_url_en", limit: 2
    t.string "fallback_url_fr", limit: 2
    t.boolean "urled"
    t.index ["acad", "slug"], name: "index_courses_on_acad_and_slug", unique: true
    t.index ["slug"], name: "index_courses_on_slug"
  end

  create_table "phds", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper", null: false
    t.string "director_sciper"
    t.string "codirector_sciper"
    t.string "name"
    t.string "cursus"
    t.integer "thesis_number"
    t.string "thesis_title", limit: 500
    t.date "date"
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codirector_sciper"], name: "index_phds_on_codirector_sciper"
    t.index ["director_sciper"], name: "index_phds_on_director_sciper"
  end

  create_table "scipers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "sciper"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "name"
    t.index ["email"], name: "index_scipers_on_email", unique: true
    t.index ["sciper"], name: "unique_scipers", unique: true
  end

  create_table "teacherships", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "course_id"
    t.string "sciper"
    t.string "role"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_teacherships_on_course_id"
  end

  create_table "texts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "signature"
    t.text "content", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "hopefully unique hash of the content", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "ip", limit: 16
    t.string "author_sciper", limit: 8
    t.string "subject_sciper", limit: 8
    t.text "object", size: :long
    t.text "object_changes", size: :long
    t.datetime "created_at"
    t.datetime "uploaded_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "ai_translations", "texts"
end
