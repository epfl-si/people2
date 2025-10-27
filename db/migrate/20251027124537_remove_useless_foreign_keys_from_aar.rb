# frozen_string_literal: true

class RemoveUselessForeignKeysFromAar < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key(:accreds_aar, to_table: :accreds) if foreign_key_exists?(:accreds_aar, to_table: :accreds)
    remove_foreign_key(:awards_aar, to_table: :awards) if foreign_key_exists?(:awards_aar, to_table: :awards)
  end
end
