# frozen_string_literal: true

class AdoptionPolicy < ApplicationPolicy
  def update?
    owner_or_su? || admin_for?(record)
  end
end
