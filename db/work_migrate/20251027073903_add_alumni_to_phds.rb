# frozen_string_literal: true

class AddAlumniToPhds < ActiveRecord::Migration[8.0]
  def up
    add_column :phds, :past, :boolean, default: false
    # rubocop:disable Rails/SkipsModelValidations
    y = Time.zone.today.year
    Phd.where('year < ? or year = ? and date is not NULL', y, y).update_all(past: true)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_column :phds, :past
  end
end
