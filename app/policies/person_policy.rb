# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  # everyone can see the person
  def show?
    true
  end

  def update?
    Rails.logger.debug(user.inspect)
    return false if user.blank?

    (user.sciper == record.sciper) || user.superuser? || user.admin_for_profile?(record)
  end

  # TODO: should be restrict to people working at 1234 or to VPSI people ?
  def show_atari?
    user.present?
  end
end
