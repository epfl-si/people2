# frozen_string_literal: true

# I didn't want to have a persistent db entry for users but couldn't manage
# to make it work. I will try again in the future although afterall it might
# be not bad to have an easy to manage list of users that did login.
# https://henrytabima.github.io/rails-setup/docs/devise/omniauth
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[oidc]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      # will raise exception if not found.
      person = Person.find(auth.info.email)
      user.sciper = person.sciper
    end
  end

  # profile argument only needs to respond_to? sciper => can also be a Person
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
    # ./bin/api.sh 'authorizations?persid=356328&status=active&type=right&authid=gestionprofils&onpersid=121157'" | jq
    # {
    #   "authorizations": [
    #     {
    #       "type": "right",
    #       "attribution": "inherited",
    #       "authid": 12,
    #       "persid": 106534,
    #       "resourceid": "11007",
    #       "accredunitid": 0,
    #       "value": "y:R:5:10077",
    #       "enddate": null,
    #       "status": "active",
    #       "workflowid": 0,
    #       "labelfr": "People - gérer les profils personnels",
    #       "labelen": "People - manage personal profiles",
    #       "name": "gestionprofils"
    #     },
    #     {
    #       "type": "right",
    #       "attribution": "inherited",
    #       "authid": 12,
    #       "persid": 106534,
    #       "resourceid": "13680",
    #       "accredunitid": 0,
    #       "value": "y:R:5:10077",
    #       "enddate": null,
    #       "status": "active",
    #       "workflowid": 0,
    #       "labelfr": "People - gérer les profils personnels",
    #       "labelen": "People - manage personal profiles",
    #       "name": "gestionprofils"
    #     },
    #     {
    #       "type": "right",
    #       "attribution": "inherited",
    #       "authid": 12,
    #     ...
    #
    aa = APIAuthGetter.new(sciper, authid: 'gestionprofils', type: 'right', onpersid: profile.sciper).fetch
    !aa.empty?
  end

  def admin?
    Rails.configuration.admin_scipers.include?(sciper)
  end
end

# class User
#   include ActiveModel::API
#   include ActiveModel::Validations
#   extend ActiveModel::Callbacks
#   extend Devise::Models

#   define_model_callbacks :validation

#   attr_accessor :email, :name, :uid

#   devise :omniauthable, omniauth_providers: %i[oidc]

#   def self.to_adapter
#     self
#   end

#   def self.from_omniauth(auth)
#     User.new(
#       email: auth.info.email,
#       name: auth.info.name,
#       uid: auth.uid,
#     )
#   end
# end
