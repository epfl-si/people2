# frozen_string_literal: true

require "net/http"
# This controller is a customized version of the standard one created with
# rails g authentication. Heavily inspired by
# https://github.com/omniauth/omniauth_openid_connect/blob/master/lib/omniauth/strategies/openid_connect.rb
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_session_url, alert: "Try again later."
  }

  # This is if we want to enable password authentication instead
  # def new
  # end
  # def create
  #   if user = User.authenticate_by(params.permit(:email_address, :password))
  #     start_new_session_for user
  #     redirect_to after_authentication_url
  #   else
  #     redirect_to new_session_path, alert: "Try another email address or password."
  #   end
  # end

  # instead of asking username/password we just redirect to the auth server
  def new
    # If I came from this app, then we go back after login
    rf = request.referer
    if rf.present?
      b = URI(rf)
      r = URI(root_url)
      session[:return_to_after_authenticating] = rf if b.host == r.host && b.path.start_with?(r.path)
    end

    cfg = Rails.application.config_for(:oidc)
    query = {
      client_id: cfg.client_id,
      response_type: "code",
      scope: "openid email profile",
      state: new_state,
      redirect_uri: callback_uri,
    }
    auth_url = URI::HTTPS.build(
      host: cfg.server,
      path: cfg.base_path + cfg.auth_path,
      query: query.to_query
    )
    redirect_to auth_url, allow_other_host: true
  end

  # once authenticated, the user is redirected back to the redirect_url
  # with two parameters:
  #  - state which is identifier of the authentication process
  #  - code  which allow the application to check with the auth server the
  #          result of the authentication
  # From official OAuth doc:
  #   Once authorization has been obtained from the end-user, the authorization
  #   server redirects the end-user's user-agent back to the client with the
  #   required binding value contained in the "state" parameter. The binding
  #   value enables the client to verify the validity of the request by matching
  #   the binding value to the user-agent's authenticated state
  def create
    unless valid_state?(params[:state])
      render plain: "Something went wrong. Try again.", status: :unauthorized
      return
    end

    code = params[:code]
    if code.blank?
      # TODO: render something more user-friendly
      render plain: "Return code from auth provider is absent", status: :unauthorized
      return
    end

    token = fetch_oidc_token(code)
    id_token = token["id_token"]

    if id_token.blank? || !valid_oidc_token?(id_token)
      # TODO: render something more user-friendly
      render plain: "Invalid ID Token", status: :unauthorized
      return
    end

    user = User.from_oidc(decode_oidc_token(id_token))
    start_new_session_for user
    redirect_to after_authentication_url
  end

  def destroy
    terminate_session
    redirect_back(fallback_location: root_path)
  end

  private

  def callback_uri
    c = URI(oidc_callback_url)
    c.query = nil
    c.to_s
  end

  def fetch_oidc_token(code)
    cfg = Rails.application.config_for(:oidc)
    uri = URI::HTTPS.build(host: cfg.server, path: cfg.base_path + cfg.token_path)
    res = Net::HTTP.post_form(uri, {
                                client_id: cfg.client_id,
                                client_secret: cfg.secret,
                                code: code,
                                grant_type: "authorization_code",
                                redirect_uri: callback_uri,
                              })
    JSON.parse(res.body)
  end

  def decode_oidc_token(token)
    _, payload, = token.split(".")
    payload += "=" * (4 - payload.length % 4)
    JSON.parse(Base64.decode64(payload))
  end

  def valid_oidc_token?(token)
    data = decode_oidc_token(token)
    exp = data["exp"]
    return false if exp.nil? || Time.zone.at(exp) < Time.zone.now

    true
  rescue JSON::ParserError
    Rails.logger.error("Strange Token: #{token}")
    false
  end

  def new_state
    session[:oidc_state] = SecureRandom.hex(16)
  end

  def valid_state?(state)
    session.delete(:oidc_state) == state
  end
end
