# frozen_string_literal: true

class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.string     :type, null: false
      t.string     :subkind, null: true
      t.references :profile, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :model_box, null: true, foreign_key: true
      t.string     :title_en
      t.string     :title_fr
      t.string     :title_it
      t.string     :title_de
      t.boolean    :show_title, default: true
      t.boolean    :locked_title, default: false
      t.integer    :visibility, default: 4 # 0=public, 1=intranet, 2=authenticated, 3=owner, 4=hidden
      t.integer    :position, null: false
      t.text       :data, null: true
      t.timestamps
    end
  end
end
