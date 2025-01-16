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

ActiveRecord::Schema[7.1].define(version: 2023_06_06_141719) do
  create_table "accreds", primary_key: ["sciper", "unit"], charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.string "unit", limit: 6, default: "", null: false
    t.string "accred_show", limit: 1, default: ""
    t.integer "ordre", limit: 1, default: 0, null: false
    t.string "accred_tree_show", limit: 1
    t.string "addr_hide", limit: 1
    t.string "office_hide", limit: 32
  end

  create_table "achievements", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, null: false
    t.string "cvlang", limit: 2
    t.timestamp "created_at", default: -> { "current_timestamp()" }, null: false
    t.integer "year", null: false
    t.column "category", "enum('education','research','innovation','awards','other')", default: "other"
    t.text "description", null: false
    t.string "url", limit: 256
    t.integer "ordre", limit: 1
    t.index ["sciper"], name: "sciper"
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

  create_table "artists", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "awards", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "ordre"
    t.string "sciper", limit: 10, null: false
    t.string "title", null: false
    t.string "grantedby"
    t.string "dates", limit: 45
    t.string "url"
    t.integer "year"
    t.string "category", limit: 64
    t.string "origin", limit: 32
    t.index ["sciper"], name: "sciper"
  end

  create_table "boxes", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.string "label", limit: 50
    t.text "content", size: :medium
    t.string "box_show", limit: 1, default: ""
    t.string "position", limit: 1, default: "", null: false
    t.integer "ordre", limit: 1, default: 0, null: false
    t.string "cvlang", limit: 2, default: "", null: false
    t.string "sys", limit: 1
    t.text "src", size: :long
    t.timestamp "ts", default: -> { "current_timestamp() ON UPDATE current_timestamp()" }, null: false
    t.text "contentutf8"
    t.index ["sciper"], name: "sciper"
  end

  create_table "boxes_old", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.string "label", limit: 50
    t.text "content"
    t.string "box_show", limit: 1, default: ""
    t.string "position", limit: 1, default: "", null: false
    t.integer "ordre", limit: 1, default: 0, null: false
    t.string "cvlang", limit: 2, default: "", null: false
    t.string "sys", limit: 1
  end

  create_table "common", primary_key: "sciper", id: { type: :string, limit: 100, default: "" }, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "photo_show", limit: 1, default: ""
    t.string "photo_ext", limit: 1, default: ""
    t.string "fax", limit: 100, default: ""
    t.string "fax_show", limit: 1, default: ""
    t.string "tel_prive", limit: 100, default: ""
    t.string "tel_prive_show", limit: 1, default: ""
    t.string "funct_show", limit: 1, default: ""
    t.string "all_doct_act", limit: 1, default: ""
    t.string "mainunit_show", limit: 1, default: ""
    t.string "datenaiss_show", limit: 1, default: ""
    t.string "origine", limit: 100, default: ""
    t.string "origine_show", limit: 1, default: ""
    t.string "nat", limit: 100, default: ""
    t.string "nat_show", limit: 1, default: ""
    t.string "web_perso", limit: 256, default: ""
    t.string "web_perso_show", limit: 1, default: ""
    t.string "pub_src", limit: 1, default: ""
    t.string "infoQuery", default: ""
    t.string "infoBasketID", limit: 20, default: ""
    t.string "infoFormat", limit: 20, default: ""
    t.string "pub_show", limit: 1, default: ""
    t.string "tromb_show", limit: 1, default: ""
    t.datetime "date_maj_pub", precision: nil
    t.string "profil_chercheur", limit: 1
    t.string "edu_show", limit: 1
    t.string "parcours_show", limit: 1
    t.string "defaultcv", limit: 2
    t.integer "photo_ts"
    t.string "research_tab", limit: 1
    t.boolean "use_inclusive_job", default: false
    t.boolean "email_show", default: true
    t.string "email_replacement", limit: 64
  end

  create_table "cv", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.string "cvlang", limit: 2, default: "", null: false
    t.datetime "datecr", precision: nil, null: false
    t.datetime "datemod", precision: nil, null: false
    t.string "creator", limit: 6, default: "", null: false
    t.string "lastmodby", limit: 6, default: "", null: false
    t.string "profile_show", limit: 1, default: ""
    t.text "curriculum", size: :medium
    t.string "curriculum_show", limit: 1
    t.text "expertise", size: :medium
    t.string "expertise_show", limit: 1, default: ""
    t.text "mission", size: :medium
    t.string "mission_show", limit: 1, default: ""
    t.string "titre", limit: 100, default: ""
    t.string "titre_show", limit: 1, default: ""
    t.string "special", limit: 100
    t.index ["sciper", "cvlang"], name: "cv_lang"
  end

  create_table "edu", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "ordre", default: 0, null: false
    t.string "sciper", limit: 10, default: "", null: false
    t.string "title", default: "", null: false
    t.string "field", default: "", null: false
    t.string "director", default: "", null: false
    t.string "univ", default: "", null: false
    t.string "dates", limit: 100, default: "", null: false
    t.index ["sciper"], name: "sciper"
  end

  create_table "exceptions", primary_key: "sciper", id: { type: :string, limit: 10, default: "" }, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "admin", limit: 10, default: "", null: false
    t.timestamp "date", default: -> { "current_timestamp() ON UPDATE current_timestamp()" }, null: false
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

  create_table "logs", id: { type: :integer, unsigned: true }, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.timestamp "ts", null: false
    t.string "sciper", limit: 8, default: "", null: false
    t.string "scipertodo", limit: 8, default: "", null: false
    t.text "msg", null: false
    t.index ["ts", "sciper"], name: "indx"
  end

  create_table "model_boxes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "kind", default: "RichTextBox"
    t.string "subkind"
    t.bigint "section_id", null: false
    t.string "label", null: false
    t.string "title_en", null: false
    t.string "title_fr", null: false
    t.string "title_it", null: false
    t.string "title_de", null: false
    t.boolean "show_title", default: true
    t.integer "position", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_model_boxes_on_section_id"
  end

  create_table "parcours", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "ordre", default: 0, null: false
    t.string "sciper", limit: 10, default: "", null: false
    t.string "title", default: "", null: false
    t.string "field", default: "", null: false
    t.string "univ", default: "", null: false
    t.string "dates", limit: 100, default: "", null: false
    t.index ["sciper"], name: "sciper"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "sciper"
    t.boolean "show_birthday", default: false
    t.boolean "show_function", default: false
    t.boolean "show_nationality", default: false
    t.boolean "show_phone", default: false
    t.boolean "show_photo", default: true
    t.boolean "show_weburl", default: false
    t.string "force_lang"
    t.string "default_lang"
    t.string "personal_web_url"
    t.string "phone"
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
    t.index ["sciper"], name: "unique_scipers", unique: true
  end

  create_table "profresearch", primary_key: "sciper", id: :integer, default: 0, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.text "col1"
    t.text "col2"
    t.text "col3"
    t.text "col4"
    t.text "col5"
    t.text "skills"
    t.text "parcours"
    t.string "parcours_show", limit: 1, default: "1"
    t.text "awds"
    t.string "awds_show", limit: 1, default: "1"
    t.text "col9"
    t.text "wos"
    t.string "wos_show", limit: 1, default: "1"
    t.text "orcid"
    t.string "orcid_show", limit: 1, default: "1"
    t.text "biblioprofile"
    t.text "scopus"
    t.string "scopus_show", limit: 1, default: "1"
    t.text "col11"
    t.text "col12"
    t.text "col13"
    t.text "googlescholar"
    t.string "googlescholar_show", limit: 1, default: "1"
  end

  create_table "publications", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.text "auteurspub"
    t.text "titrepub"
    t.text "revuepub"
    t.integer "ordre", limit: 1
    t.string "urlpub", limit: 100, default: ""
    t.string "showpub", limit: 1, default: ""
    t.index ["sciper"], name: "sciper"
  end

  create_table "redirects", id: { type: :integer, unsigned: true }, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "sciper", limit: 6, default: "", null: false
    t.string "url", limit: 128, default: "", null: false
    t.string "ns", limit: 32, default: "", null: false
    t.index ["ns"], name: "ns"
    t.index ["sciper"], name: "sciper"
  end

  create_table "research_ids", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "sciper", limit: 10
    t.string "tag", limit: 16
    t.string "content", limit: 128
    t.integer "ordre"
    t.string "id_show", limit: 1
    t.index ["sciper"], name: "sciper"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "title_en"
    t.string "title_fr"
    t.string "title_it"
    t.string "title_de"
    t.string "label"
    t.string "zone"
    t.integer "position", null: false
    t.boolean "show_title"
    t.boolean "create_allowed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teachingact", primary_key: "sciper", id: { type: :string, limit: 6, default: "" }, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.text "pdocs", size: :medium
    t.text "tsect", size: :medium
    t.text "phdstuds", size: :medium
    t.text "cours", size: :long
    t.timestamp "ts", default: -> { "current_timestamp() ON UPDATE current_timestamp()" }, null: false
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
  add_foreign_key "items", "artists"
  add_foreign_key "model_boxes", "sections"
end
