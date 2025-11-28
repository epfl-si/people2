# frozen_string_literal: true

class AddAudienceToServiceAuth < ActiveRecord::Migration[8.0]
  def change
    add_column :service_auths, :audience, :integer, default: 0
  end
end
