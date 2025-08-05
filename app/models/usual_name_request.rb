# frozen_string_literal: true

class UsualNameRequest < ApplicationRecord
  belongs_to :profile
  after_create :deliver

  # Changed model name but I keep the table as is because we might need to
  # make this a child model of a generic NameChangeRequest that could be
  # used both for usual as well as official name change requests
  self.table_name = 'name_change_requests'

  validates :new_first, :new_last, :reason, presence: true

  def self.for(profile)
    name = profile.name

    profile.usual_name_requests.build(
      old_first: name.display_first,
      old_last: name.display_last
    )
  end

  def person
    profile&.person
  end

  private

  def deliver
    ProfileChangeMailer.with(usual_name_request: self)
                       .usual_name_request
                       .deliver_later
  end
end
