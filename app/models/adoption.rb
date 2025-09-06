# frozen_string_literal: true

class Adoption < ApplicationRecord
  validates :sciper, uniqueness: true
  validates :email, uniqueness: { allow_blank: true }
  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }
  after_update :update_sciper_status

  def self.clear_cache
    Rails.cache.delete_matched("adoptions/*")
  end

  def self.for_sciper_or_name(v)
    s = v.is_a?(Integer) || v =~ /^\d{6}$/ ? { sciper: v } : { email: "#{v}@epfl.ch" }
    where(s)
  end

  def self.not_yet(sciper_or_email)
    s = for_sciper_or_name(sciper_or_email).first
    s && !s.accepted? ? s : nil
  end

  def path
    @path ||= (email.present? ? email.sub("@epfl.ch", "") : sciper)
  end

  # Fetch html profile from legacy server and rewrite edit link so it points to the new app
  def content(locale, admin_data_html: nil, force: false)
    profile = Profile.for_sciper(sciper)
    r = Regexp.new('href="/([a-z0-9\-.]+)/edit')
    res = if profile.present?
            legacy_content(locale, force: force).gsub(r, "href=\"/profiles/#{profile.id}/edit\"")
          else
            legacy_content(locale, force: force).gsub(r, "href=\"/people/#{sciper}/profile/new\"")
          end
    res.sub!('<!-- %%%%% ADMIN_DATA_HERE %%%%% -->', admin_data_html) if admin_data_html.present?
    res
  end

  def reimport
    Profile.for_sciper(sciper).destroy
    per = Person.find(sciper)
    per.profile!
    save
  end

  # edit_profile_path(@profile) : new_person_profile_path(sciper: @person.sciper)

  # private

  def update_sciper_status
    s = Work::Sciper.find(sciper)
    s.status = Work::Sciper::STATUS_MIGRATED
    s.save!
  end

  # Fetch html profile from legacy server and rewrite links
  def legacy_content(locale, force: false)
    ck = "#{cache_key}/#{locale}"
    if Rails.configuration.legacy_pages_cache.positive?
      if force
        Rails.logger.debug("Expiring cache for key: #{ck}")
        Rails.cache.delete(ck)
      end
      Rails.logger.debug("Fetching cache for key: #{ck}")
      Rails.cache.fetch(cache_key, expires_in: Rails.configuration.legacy_pages_cache.days) do
        Rails.logger.debug("Cache miss for key: #{ck}")
        fetch_legacy_content(locale)
      end
    else
      fetch_legacy_content(locale)
    end
  end

  def fetch_legacy_content(locale)
    uri = URI.join(Rails.configuration.legacy_base_url, path)
    uri.query = "lang=#{locale}"
    body = Net::HTTP.get(uri)
    dbody = Legacy.char_deshit(body)
    dbody.gsub(
      Regexp.new('(src|href)="/(private/common|images|js|css)/'),
      "\\1=\"#{Rails.configuration.legacy_base_url}/\\2/"
    )
  end
end
