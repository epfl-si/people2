# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  # everyone can see the person
  def show?
    true
  end

  def update?
    owner_or_su? || admin_for?(record)
  end

  # TODO: should be restrict to people working at 1234 or to VPSI people ?
  def show_atari?
    user.present?
  end
end
