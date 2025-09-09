# frozen_string_literal: true

class IncreaseJournalColumnWidth < ActiveRecord::Migration[8.0]
  def up
    change_table :publications, bulk: true do |t|
      t.string :url, limit: 1024
      t.string :journal, limit: 1024
    end
  end

  def down
    change_table :publications, bulk: true do |t|
      t.string :url, limit: 255
      t.string :journal, limit: 255
    end
  end
end
