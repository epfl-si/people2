# frozen_string_literal: true

class CamiproToSource < ActiveRecord::Migration[8.0]
  def up
    # Add a new column 'source' to the 'pictures' table
    add_column :pictures, :source, :string, null: true

    # Update existing records to set the 'source' column to 'camipro'
    Picture.where(camipro: true).find_each do |picture|
      picture.update(source: 'camipro')
    end

    remove_column :pictures, :camipro
  end

  def down
    # Add a new column 'camipro' to the 'pictures' table
    add_column :pictures, :camipro, :boolean, null: false, default: false

    # Update existing records to set the 'camipro' column to true
    Picture.where(source: 'camipro').find_each do |picture|
      picture.update(camipro: true)
    end

    remove_column :pictures, :source
  end
end
