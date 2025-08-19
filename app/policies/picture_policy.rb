# frozen_string_literal: true

class PicturePolicy < ApplicationPolicy
  # «Pour des raisons légales, il est impossible de déléguer la gestion de sa photo de profil à autrui.»
  # I still keep supersuer for debugging / support purpose
  def update?
    owner_or_su?
  end
end
