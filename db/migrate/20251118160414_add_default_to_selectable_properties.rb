# frozen_string_literal: true

class AddDefaultToSelectableProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :selectable_properties, :default, :boolean, default: false, null: false
  end
end
