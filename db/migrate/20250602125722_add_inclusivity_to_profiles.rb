# frozen_string_literal: true

class AddInclusivityToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :inclusivity, :boolean, default: false, null: false
  end
end
