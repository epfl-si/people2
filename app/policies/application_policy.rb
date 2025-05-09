# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.user_id == user.id
  #  end

  def owner_or_su?
    return false if user.blank?

    (user.sciper == record.sciper) || user.superuser?
  end

  def admin_for?(record)
    return false if user.blank?
    return false unless record.respond_to?(:sciper)

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
    all_admins = APIAuthGetter.call(authid: 'gestionprofils', type: 'right', onpersid: record.sciper)
    !all_admins.find { |r| r['persid'].to_i == user.sciper.to_i }.nil?
  end

  authorize :user, allow_nil: true
end
