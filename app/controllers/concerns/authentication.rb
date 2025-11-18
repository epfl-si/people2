# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      # before_action :resume_session, **options
    end
  end

  private

  RECENT_MAX_AGE = 15.minutes

  def authenticated?
    resume_session
  end

  def require_authentication
    Rails.logger.debug "%%%% require_authentication"
    resume_session || request_authentication
  end

  # This is similar to require_authentication but it considers the session expired
  # quite early. This is to make sure that the JWT is recent and safe to use.
  # TODO: this does not work because M$ returns the same JWT token until it expires.
  #       Therefore we still have an obsolete token when we need to use it :(
  def require_recent_authentication
    Rails.logger.debug "%%%% require_recent_authentication"
    cs = resume_session
    if cs.blank?
      # this should never happen because of the :require_authentication before_action
      request_authentication
    elsif (Time.zone.now - cs.created_at) > RECENT_MAX_AGE
      terminate_session
      # I was hoping to obtain a new token by reloading the page. Off-course not!
      # request_authentication
      redirect_to request.url
    end
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  # TODO: restore redirect back functionality for the momen we remove it to avoid loops
  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user, jwt = nil)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, jwt: jwt).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
