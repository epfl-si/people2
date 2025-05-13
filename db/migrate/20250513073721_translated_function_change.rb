# frozen_string_literal: true

class TranslatedFunctionChange < ActiveRecord::Migration[8.0]
  def change
    remove_column(:function_changes, :function, type: :string)
    change_table :function_changes, bulk: true do |t|
      t.string :function_en
      t.string :function_fr
      t.string :function_it
      t.string :function_de
    end
  end
end
