# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    return false if user.blank?

    # `user` is a performing subject,
    # `record` is a target object (the profile in this case)
    # in order fastest -> slowest
    (user.sciper == record.sciper) || user.superuser? || user.admin_for_profile?(record)
  end
end
