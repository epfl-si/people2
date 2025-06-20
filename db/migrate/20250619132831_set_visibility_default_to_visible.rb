# frozen_string_literal: true

class SetVisibilityDefaultToVisible < ActiveRecord::Migration[8.0]
  def up
    change_column_default :achievements, :visibility, AudienceLimitable::VISIBLE
    change_column_default :awards, :visibility, AudienceLimitable::VISIBLE
    change_column_default :boxes, :visibility, AudienceLimitable::WORLD
    change_column_default :educations, :visibility, AudienceLimitable::VISIBLE
    change_column_default :infosciences, :visibility, AudienceLimitable::VISIBLE
    change_column_default :publications, :visibility, AudienceLimitable::VISIBLE
    change_column_default :socials, :visibility, AudienceLimitable::VISIBLE
  end

  def down
    change_column_default :achievements, :visibility, AudienceLimitable::HIDDEN
    change_column_default :awards, :visibility, AudienceLimitable::HIDDEN
    change_column_default :boxes, :visibility, AudienceLimitable::NOBODY
    change_column_default :educations, :visibility, AudienceLimitable::HIDDEN
    change_column_default :infosciences, :visibility, AudienceLimitable::HIDDEN
    change_column_default :publications, :visibility, AudienceLimitable::HIDDEN
    change_column_default :socials, :visibility, AudienceLimitable::HIDDEN
  end
end
