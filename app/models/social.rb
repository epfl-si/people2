# frozen_string_literal: true

# TODO: this class mimics the logic of the equivalent in people legacy.
#       May be there is a nicer way of doing this.

class Social < ApplicationRecord
  include AudienceLimitable

  RESEARCH_IDS_LIST = [
    {
      tag: 'orcid',
      # img: 'ORCIDiD_icon16x16.png',
      url: 'https://orcid.org/XXX',
      placeholder: '0000-0002-1825-0097',
      label: 'ORCID',
      position: 0,
      icon: "icon-orcid",
      re: /^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/,
      help: {
        'en' => 'https://orcid-integration.epfl.ch/',
        'fr' => 'https://orcid-integration.epfl.ch/'
      }
    },
    {
      tag: 'wos',
      # img: 'publons.png',
      url: 'https://www.webofscience.com/wos/author/record/XXX',
      placeholder: 'AAX-5119-2020',
      label: 'Publons - Web of Science ID',
      position: 1,
      icon: "icon-wos",
      re: /^([A-Z]+-[0-9]{4}-[0-9]{4}|[0-9])+$/
    },
    {
      tag: 'scopus',
      img: 'scopus.png',
      url: 'https://www.scopus.com/authid/detail.uri?authorId=XXX',
      placeholder: '57192201516',
      label: 'Scopus ID',
      position: 2,
      # icon: "icon-scopus",
      re: /^[0-9]+$/
    },
    {
      tag: 'googlescholar',
      # img: 'google-scholar.svg',
      url: 'https://scholar.google.com/citations?user=XXX',
      placeholder: 'abcdEFGhiJKLMno',
      label: 'Google Scholar ID',
      position: 3,
      icon: 'icon-googlescholar',
      re: /^[0-9a-zA-Z.-]+$/
    },
    {
      tag: 'linkedin',
      # img: 'linkedin.jpg',
      url: 'https://www.linkedin.com/in/XXX',
      placeholder: 'john-doe-12345',
      label: 'Linkedin',
      position: 4,
      icon: 'linkedin',
      re: %r{^[a-z][a-z0-9-]+/?$}
    },
    {
      tag: 'github',
      # img: 'github.png',
      url: 'https://github.com/XXX',
      placeholder: 'username',
      label: 'GitHub',
      position: 5,
      icon: 'github',
      re: /^[A-Za-z0-9_.-]+$/
    },
    {
      tag: 'stack_overflow',
      # img: 'stack-overflow.svg',
      url: 'https://stackoverflow.com/users/XXX',
      placeholder: '12345678',
      label: 'Stack Overflow',
      position: 6,
      icon: 'icon-stackoverflow',
      re: /^[0-9]+$/
    },
    # TODO: the mastodon address needs to be something like @instance@username
    #       and the URL have to be recomputed accordingly.
    #       Alternatively, we can limit to epfl instance social.epfl.ch
    {
      tag: 'mastodon',
      # img: 'mastodon.png',
      url: 'https://social.epfl.ch/@XXX',
      placeholder: 'username',
      label: 'Mastodon',
      position: 7,
      icon: 'icon-mastodon',
      re: /^[A-Za-z0-9_]+$/
    },
    {
      tag: 'facebook',
      # img: 'facebook.png',
      url: 'https://www.facebook.com/XXX',
      placeholder: 'john.doe',
      label: 'Facebook',
      position: 8,
      icon: 'icon-facebook',
      re: /^[A-Za-z0-9.]+$/
    },
    {
      tag: 'instagram',
      # img: 'instagram.png',
      url: 'https://www.instagram.com/XXX',
      placeholder: '@username',
      label: 'Instagram',
      position: 9,
      icon: 'instagram',
      re: /^[A-Za-z0-9._]+$/
    },
    # {
    #   tag: # 'twitter',
    #   # img: 'twitter.png',
    #   url: 'https://twitter.com/XXX',
    #   placeholder: 'username',
    #   label: 'Twitter',
    #   position: 10,
    #   icon: 'twitter',
    #   re: /^[A-Za-z0-9_]+$/
    # },
    {
      tag: 'muskidiocy',
      url: 'https://x.com/XXX',
      placeholder: 'username',
      label: 'X (Twitter)',
      position: 99,
      icon: 'icon-x',
      re: /^[A-Za-z0-9_]+$/
    }
  ].freeze

  RESEARCH_IDS = RESEARCH_IDS_LIST.index_by { |v| v[:tag] }.freeze
  TAG_SELECT_OPTIONS = RESEARCH_IDS_LIST.map { |v| [v[:label], v[:tag]] }

  belongs_to :profile, class_name: "Profile", inverse_of: :socials

  validates :value, presence: true
  validates :tag, presence: true
  validates :tag, inclusion: { in: RESEARCH_IDS.keys }
  validate :validate_format_of_value

  validate :url_actually_exists

  before_save :ensure_sciper

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:position)
  end

  def url
    @url ||= begin
      @s = RESEARCH_IDS[tag]
      @s[:url].sub('XXX', value)
    end
  end

  def icon_class
    @s ||= RESEARCH_IDS[tag]
    @s[:icon].nil? ? '' : "social-icon-#{@s['icon']}"
  end

  def icon
    @s ||= RESEARCH_IDS[tag]
    @s[:icon]
  end

  def customicon
    @s ||= RESEARCH_IDS[tag]
    @s[:customicon]
  end

  def image
    @s ||= RESEARCH_IDS[tag]
    @s.key?(:img) ? "social/#{@s[:img]}" : nil
  end

  def label
    @s ||= RESEARCH_IDS[tag]
    @s[:label]
  end

  def url_prefix
    RESEARCH_IDS.dig(tag, 'url').gsub('XXX', '') if tag.present?
  end

  def default_position
    @s ||= RESEARCH_IDS[tag]
    @s[:position]
  end

  private

  def ensure_sciper
    sciper || profile.sciper
  end

  def validate_format_of_value
    unless RESEARCH_IDS.key?(tag)
      errors.add(:tag, I18n.t('activerecord.errors.models.social.attributes.tag.invalid'))
      return false
    end

    re = RESEARCH_IDS[tag][:re]
    return if re.match?(value)

    errors.add(:value, I18n.t('activerecord.errors.models.social.attributes.value.incorrect_format'))
    false
  end

  # TODO: fire a request to the url and check if it actually exist
  def url_actually_exists
    true
  end
end
