# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    # `user` is a performing subject,
    # `record` is a target object (the profile in this case)
    # in order fastest -> slowest
    owner_or_su? || admin_for?(record)
  end
end
