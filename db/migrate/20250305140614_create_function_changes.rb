# frozen_string_literal: true

class CreateFunctionChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :function_changes do |t|
      t.string :accreditation_id
      t.string :requested_by
      t.string :treated_by
      t.text   :accreditor_scipers
      t.string :function
      t.string :status
      t.text   :reason

      t.timestamps
    end
  end
end
