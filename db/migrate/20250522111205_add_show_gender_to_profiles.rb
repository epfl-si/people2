# frozen_string_literal: true

class AddShowInclusivityToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :show_inclusivity, :boolean, default: false, null: false
  end
end
