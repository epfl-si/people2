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

  # profile argument only needs to respond_to? sciper => can also be a Person
  # https://www.epfl.ch/campus/services/website/fr/publier-sur-le-web-epfl/people/informations/droits/
  def admin_for_profile?(profile)
    # TODO: translate from original perl implementation
    # my $RIGHT_GESPROFILE = 12;
    # my $PROP_BOTWEB      = 1 ;
    # my $units_admin = $self->{Accreds}->getAllUnitsWhereHasRight ($login_sciper, $RIGHT_GESPROFILE);
    # if ($units_admin) {
    #   foreach my $unit ($self->{Accreds}->getAllUnitsOfPerson($sciper)) {
    #     next unless $unit;
    #     return 1 if defined $units_admin->{$unit};
    #   }
    #   return 0;
    # } else {
    #   return 0
    # }
    # if `onpersid` is provided then `persid` is ignored. Therefore I have to do the filtering here
    all_admins = APIAuthGetter.call(authid: 'gestionprofils', type: 'right', onpersid: profile.sciper)
    !all_admins.find { |r| r['persid'].to_i == sciper.to_i }.nil?
  end

  def superuser?
    Rails.configuration.superusers.include?(sciper)
  end
end
