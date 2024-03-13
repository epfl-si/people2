# frozen_string_literal: true

class AddFavoritePicture < ActiveRecord::Migration[7.0]
  def change
    add_reference :profiles, :selected_picture, null: true
    add_reference :profiles, :camipro_picture, null: true
  end
end
