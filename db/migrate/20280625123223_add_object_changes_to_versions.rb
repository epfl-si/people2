# frozen_string_literal: true

# This migration adds the optional `object_changes` column in which PaperTrail
# will store the `changes` diff for each update event.
# It also adds few other columns needed for OPDo spyware
class AddObjectChangesToVersions < ActiveRecord::Migration[8.0]
  # The largest text column available in all supported RDBMS.
  # See `create_versions.rb` for details.
  TEXT_BYTES = 1_073_741_823

  def change
    change_table :versions, bulk: true do |t|
      t.string   :ip, null: true, limit: 16
      t.string   :author_sciper, limit: 8
      t.string   :subject_sciper, limit: 8
      t.text     :object_changes, limit: TEXT_BYTES
    end
  end
end
