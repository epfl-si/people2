# frozen_string_literal: true

class User < ApplicationRecord
  # has_secure_password
  has_many :sessions, dependent: :destroy

  def self.from_oidc(data)
    # entraid returns the sciper as uniqueid while keycloak needs some extra
    # configuration which I don't have the patience to figure out and add this
    # workaround instead for determining the sciper from the email address
    email = data["email"]
    raise "Invalid data from oidc auth server" if email.blank?

    sciper = data["uniqueid"] || data["sciper"] || Person.find(email)&.sciper
    raise "Could not determine user sciper" if sciper.blank?

    username = data['username'] || data['gaspar'] || data['sciper']
    raise "Could not determine user username" if username.blank?

    User.create_with(
      email: email,
      name: "#{data['given_name']} #{data['family_name']}",
      username: username,
      provider: 'oidc'
    ).find_or_create_by(sciper: sciper)
  end

  def superuser?
    Rails.configuration.superusers.include?(sciper)
  end
end
