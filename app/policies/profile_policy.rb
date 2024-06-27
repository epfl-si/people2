# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  # everyone can see any post
  def show?
    true
  end

  def update?
    Rails.logger.debug(user.inspect)
    # `user` is a performing subject,
    # `record` is a target object (the profile in this case)
    # in order fastest -> slowest
    (user.sciper == record.sciper) || user.admin? || user.admin_for_profile?(record)
  end
end
