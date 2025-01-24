# frozen_string_literal: true

class CreateScipers < ActiveRecord::Migration[7.1]
  # def connection
  #   @connection = ActiveRecord::Base.establish_connection("sdmstore_#{Rails.env}").connection
  # end

  def change
    create_table :scipers do |t|
      t.string :sciper, index: { unique: true, name: 'unique_scipers' }
      # 0: unchecked
      # 1: left EPFL
      # 2: still at EPFL (valid accred)
      # 3: still at EPFL and can have profile page
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
