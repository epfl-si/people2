# frozen_string_literal: true

class NameChangeRequest < ApplicationRecord
  belongs_to :profile

  validates :new_first, :new_last, :reason, presence: true

  def self.for(profile)
    name = profile.name
    return nil unless name.customizable?

    profile.name_change_requests.build(
      old_first: name.usual_first || name.official_first,
      old_last: name.usual_last || name.official_last
    )
  end

  def person
    profile&.person
  end
end
