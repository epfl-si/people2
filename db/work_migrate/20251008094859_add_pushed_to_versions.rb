# frozen_string_literal: true

class AddPushedToVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :versions, :uploaded_at, :datetime, default: nil
  end
end
