# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class IncreaseAdminTranslationsSize < ActiveRecord::Migration[8.0]
  def up
    # change_table :admin_translations, bulk: true do |t|
    #   t.string :en, limit: 1000
    #   t.string :fr, limit: 1000
    #   t.string :it, limit: 1000
    #   t.string :de, limit: 1000
    # end
    change_column :admin_translations, :en, :string, limit: 1000
    change_column :admin_translations, :fr, :string, limit: 1000
    change_column :admin_translations, :it, :string, limit: 1000
    change_column :admin_translations, :de, :string, limit: 1000
  end

  def down
    # nothing to roll back
  end
end
# rubocop:enable Rails/BulkChangeTable
