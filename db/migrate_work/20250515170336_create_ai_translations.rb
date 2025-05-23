# frozen_string_literal: true

class CreateAiTranslations < ActiveRecord::Migration[8.0]
  MAXCONTENT = 2_097_152
  def change
    # TODO: do we need to disable_joins: true to belongs_to ?
    create_table :texts do |t|
      # t.references :record, null: false, polymorphic: true
      # t.string :name, null: false
      t.string :signature, index: { unique: true, name: "hopefully unique hash of the content" }
      t.text :content, limit: MAXCONTENT

      t.timestamps
    end
    create_table :ai_translations do |t|
      t.references :text, null: false, foreign_key: true
      t.string :ai_model, null: false
      t.float :confidence, null: true
      t.string :lang, null: true
      t.text :content_en, null: true, limit: MAXCONTENT
      t.text :content_fr, null: true, limit: MAXCONTENT
      t.text :content_it, null: true, limit: MAXCONTENT
      t.text :content_de, null: true, limit: MAXCONTENT

      t.timestamps
    end
  end
end
