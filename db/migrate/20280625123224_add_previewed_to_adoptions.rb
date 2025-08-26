# frozen_string_literal: true

class AddPreviewedToAdoptions < ActiveRecord::Migration[8.0]
  def up
    add_column :adoptions, :previewed, :boolean, default: false, null: false
    # rubocop:disable Rails/SkipsModelValidations
    Adoption.where(previewed: nil).update_all(previewed: false)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_column :adoptions, :previewed
  end
end
