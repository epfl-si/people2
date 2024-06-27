# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  # everyone can see any post
  def show?
    true
  end

  def update?
    Rails.logger.debug(user.inspect)
    # `user` is a performing subject,
    # `record` is a target object (post we want to update)
    # user.admin? || (user.id == record.user_id)
    user.sciper == record.sciper
  end
end
