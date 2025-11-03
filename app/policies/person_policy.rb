# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  # everyone can see the person
  def show?
    record.visible_profile?
  end

  def update?
    record.editable_profile? && (owner_or_su? || admin_for?(record))
  end

  def confidential_edit?
    owner?
  end

  # TODO: should be restrict to people working at 1234 or to VPSI people ?
  # We have restored admin_data. For the moment we disable atari
  def show_atari?
    # user.present?
    false
  end

  def show_admin_data?
    (Current.audience > AudienceLimitable::WORLD) && user.present?
  end

  def show_personal_data?
    owner_or_su?
  end
end
