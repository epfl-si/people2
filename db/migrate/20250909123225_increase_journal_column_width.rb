# frozen_string_literal: true

class IncreaseJournalColumnWidth < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/BulkChangeTable
  def up
    change_column :publications, :url, limit: 1024
    change_column :publications, :journal, limit: 1024
  end

  def down
    change_column :publications, :url, limit: 255
    change_column :publications, :journal, limit: 255
  end
  # rubocop:enable Rails/BulkChangeTable
end
