# frozen_string_literal: true

class AddSolidError < ActiveRecord::Migration[8.0]
  def change
    create_table "solid_errors_errors", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
      t.text "exception_class", null: false
      t.text "message", null: false
      t.text "severity", null: false
      t.text "source"
      t.datetime "resolved_at"
      t.string "fingerprint", limit: 64, null: false
      t.index ["fingerprint"], name: "index_solid_errors_on_fingerprint", unique: true
      t.index ["resolved_at"], name: "index_solid_errors_on_resolved_at"
      t.timestamps
    end

    create_table "solid_errors_occurrences", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci",
                                             force: :cascade do |t|
      # t.references :error, null: false, foreign_key: true
      t.bigint "error_id", null: false
      t.text "backtrace"
      t.text "context", size: :long, collation: "utf8mb4_bin"
      t.timestamps
    end
    add_foreign_key "solid_errors_occurrences", "solid_errors_errors", column: "error_id"
  end
end
