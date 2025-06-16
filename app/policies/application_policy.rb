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
  def sciper_for(v)
    if v.respond_to? :sciper
      v.sciper.to_i
    elsif v.respond_to? :profile
      v.profile.sciper.to_i
    end
  end

  def owner?
    return false if user.blank?
    return false if (rs = sciper_for(record)).nil?

    user.sciper.to_i == rs.to_i
  end

  def owner_or_su?
    return false if user.blank?

    owner? || user.superuser?
  end

  def admin_for?(record)
    return false if user.blank?

    rs = sciper_for(record)
    return false if rs.nil?

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
    all_admins = APIAuthGetter.call(authid: 'gestionprofils', type: 'right', onpersid: rs)
    !all_admins.find { |r| r['persid'].to_i == user.sciper.to_i }.nil?
  end

  authorize :user, allow_nil: true
end
