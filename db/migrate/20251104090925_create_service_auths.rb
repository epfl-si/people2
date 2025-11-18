# frozen_string_literal: true

class CreateServiceAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :service_auths do |t|
      t.string :type, null: false
      t.string :service, null: false
      t.text   :subnet
      t.string :user
      t.string :password
      t.string :comment
      t.string :email
      t.timestamps
    end
  end
end
