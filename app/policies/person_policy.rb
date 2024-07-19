# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  # everyone can see the person
  def show?
    true
  end

  def update?
    Rails.logger.debug(user.inspect)
    (user.sciper == record.sciper) || user.admin? || user.admin_for_profile?(record)
  end
end
