# frozen_string_literal: true

class PicturePolicy < ApplicationPolicy
  # «Pour des raisons légales, il est impossible de déléguer la gestion de sa photo de profil à autrui.»
  def update?
    owner?
  end
end
