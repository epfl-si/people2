# frozen_string_literal: true

class AddJwtToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :jwt, :text
  end
end
