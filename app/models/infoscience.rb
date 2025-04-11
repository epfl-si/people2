# frozen_string_literal: true

class Infoscience < ApplicationRecord
  belongs_to :profile
  include AudienceLimitable
  include Translatable
  include IndexBoxable
  audience_limit
  translates :title
  positioned on: :profile

  before_validation :sanitize_url

  # validates :t_title, translatability: true

  # TODO: more than validating the link should be sanitized:
  # https://infoscience-exports.epfl.ch/[0-9]+
  URLRE1 = Regexp.new('^\s*(https://infoscience-exports\.epfl\.ch/[0-9]+)')

  validate :url_format

  validates :url, uniqueness: true

  delegate :sciper, to: :profile

  def t_content(_primary_locale = nil, _fallback_locale = nil)
    @t_content ||= InfoscienceGetter.call(url: url)
    # infoscience-exports currently does not provide localized exports but we prepare for it
    # primary_lang ||= Current.primary_lang || I18n.locale
    # fallback_lang ||= Current.translations || %w[en fr it de]
    # lang = ([primary_lang] + fallback_lang).first
    # t_url = "#{url}?lang=#{lang}" # or somethig more elaborate and URI based
    # @content[lang] ||= InfoscienceGetter.call(url: t_url)
    # @content[lang]
  end

  def url_format
    if [URLRE1].any? { |r| url =~ r }
      true
    else
      errors.add(:url, :invalid_format)
      false
    end
  end

  private

  def sanitize_url
    # We do not discard it so it can still be edited after validation error
    return unless (m = URLRE1.match(url))

    # final url is of the form https://infoscience-exports.epfl.ch/4617/
    self.url = "#{m[1]}/"
  end
end
