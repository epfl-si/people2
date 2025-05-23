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

ActiveRecord::Schema[8.0].define(version: 2025_05_15_170336) do
  create_table "admin_translations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "file"
    t.string "key"
    t.string "en"
    t.string "fr"
    t.string "it"
    t.string "de"
    t.boolean "done", default: false
    t.boolean "auto", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key", "file"], name: "index_admin_translations_on_key_and_file", unique: true
  end

  create_table "ai_translations", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
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

  create_table "scipers", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sciper"], name: "unique_scipers", unique: true
  end

  create_table "texts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "signature"
    t.text "content", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signature"], name: "hopefully unique hash of the content", unique: true
  end

  add_foreign_key "ai_translations", "texts"
end
