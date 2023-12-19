# frozen_string_literal: true

class AddFavoritePicture < ActiveRecord::Migration[7.0]
  def change
    add_reference :cvs, :profile_picture, null: true, foreign_key: true
  end
end
