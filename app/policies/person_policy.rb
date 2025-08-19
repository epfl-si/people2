# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  # everyone can see the person
  def show?
    record.visible_profile?
  end

  def update?
    record.editable_profile? && (owner_or_su? || admin_for?(record))
  end

  # TODO: should be restrict to people working at 1234 or to VPSI people ?
  def show_atari?
    user.present?
  end

  def show_personal_data?
    owner_or_su?
  end
end
