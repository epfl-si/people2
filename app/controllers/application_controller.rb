# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :register_client_origin

  # rescue_from ActionPolicy::Unauthorized do |_exception|
  #   redirect_to "/401"
  # end
  DESCS = {
    "116080" => "profile with forced french language and some bio box",
    "243371" => "very little data but usual name different from official one",
    "121769" => "nothing special but its me ;)",
    "229105" => "a professor with a lot of affiliations",
    "110635" => "a standard prof",
    "126003" => "a prof with various affiliations and links",
    "107931" => "a teacher",
    "363674" => "a student",
    "173563" => "A person whose profile should be created the first edit",
    "185853" => "an external for which there should be no people page",
    "195348" => "Another external for which there should be no people page",
    "123456" => "a (fake) existing person with redirect applied",
  }.freeze
  def devindex
    @data = []
    Profile.all.find_each do |profile|
      person = profile.person
      d = {
        name: person.name.display.to_s,
        sciper: profile.sciper.to_s,
        email: person.email_user.to_s,
        desc: DESCS[profile.sciper] || "Automatic Import",
      }
      @data << OpenStruct.new(d)
    end
  end

  def self.unique_counter_value
    @indx ||= 0
    @indx += 1
    @indx
  end

  def default_url_options
    { lang: I18n.locale }
  end

  def compute_audience(sciper)
    @audience = if user_signed_in?
                  if current_user.sciper == sciper
                    3
                  else
                    2
                  end
                elsif @is_intranet_client
                  1
                else
                  0
                end
    return unless Rails.env.development?

    fe = ENV.fetch('FORCE_AUDIENCE', false)
    return unless fe

    @original_audience = @audience
    @audience = [[0, fe.to_i].max, 3].min
  end

  private

  def switch_locale(&action)
    locale = params[:lang] || I18n.default_locale
    Thread.current[:primary_lang] = locale
    Thread.current[:fallback_lang] = I18n.default_locale
    Thread.current[:gender] = nil
    I18n.with_locale(locale, &action)
  end

  # TODO: This is not the correct way of finding internal clients. The reliable
  # way is to check if X-EPFL-Internal header is set in the request.
  def register_client_origin
    @is_intranet_client = Rails.configuration.intranet_re.match?(request.remote_ip)
  end
end
