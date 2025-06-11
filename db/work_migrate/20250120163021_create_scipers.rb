# frozen_string_literal: true

class CreateScipers < ActiveRecord::Migration[7.1]
  # def connection
  #   @connection = ActiveRecord::Base.establish_connection("sdmstore_#{Rails.env}").connection
  # end

  def change
    create_table :scipers do |t|
      t.string :sciper, index: { unique: true, name: 'unique_scipers' }
      # STATUS_NO_PROFILE = 0
      # STATUS_WITH_LEGACY_PROFILE = 1
      # STATUS_MIGRATED = 2
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
