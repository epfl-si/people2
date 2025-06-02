# frozen_string_literal: true

class AddInclusivityToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :inclusivity, :boolean, default: false, null: false
  end
end
