# frozen_string_literal: true

# TODO: this class mimics the logic of the equivalent in people legacy.
#       May be there is a nicer way of doing this.

# TODO: orcid record should not be editable but it is not clear yet
#       where to ge the data from. It might be possible that currently
#       the library writes directly into the database!!
#       Also publons and scopus might be obtaineable from orcid itself:
#       See, for example https://orcid.org/0000-0002-8984-6584
#       have easily parseable data at the following address:
#       https://orcid.org/0000-0002-8984-6584/summary.json
#         "externalIdentifiers": [
#           {
#             "id": "930641",
#             "commonName": "ResearcherID",
#             "reference": "A-8847-2010",
#             "url": "http://www.researcherid.com/rid/A-8847-2010",
#             "validated": false
#           },
#           {
#             "id": "2615263",
#             "commonName": "Scopus Author ID",
#             "reference": "7004169597",
#             "url": "http://www.scopus.com/inward/authorDetails.url?authorID=7004169597&partnerID=MN8TOARS",
#             "validated": false
#           }
#         ],
#       On the other hand, this is not always the case. Example:
#       https://orcid.org/0000-0002-8984-6584/summary.json
#       https://orcid.org/0009-0008-7241-7119/summary.json

class Social < ApplicationRecord
  include AudienceLimitable
  audience_limit
  AUTO_MAX_AGE = 180.days
  RESEARCH_IDS_LIST = [
    {
      tag: 'orcid',
      # img: 'ORCIDiD_icon16x16.png',
      url_pattern: 'https://orcid.org/XXX',
      placeholder: '0000-0002-5489-2425',
      label: 'ORCID',
      automatic: true,
      default_position: 0,
      icon: "icon-orcid",
      re: /^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/,
      help_on_empty: 'msg.empty_orcid_help',
      help_url: 'https://orcid-integration.epfl.ch/'
    },
    {
      tag: 'wos',
      # img: 'publons.png',
      url_pattern: 'https://www.webofscience.com/wos/author/record/XXX',
      placeholder: 'AAX-5119-2020',
      label: 'Publons - Web of Science ID',
      default_position: 1,
      icon: "icon-wos",
      re: /^([A-Z]+-[0-9]{4}-[0-9]{4}|[0-9])+$/
    },
    {
      tag: 'scopus',
      img: 'scopus.png',
      url_pattern: 'https://www.scopus.com/authid/detail.uri?authorId=XXX',
      placeholder: '23049566200',
      label: 'Scopus ID',
      default_position: 2,
      # icon: "icon-scopus",
      re: /^[0-9]+$/
    },
    {
      tag: 'googlescholar',
      # img: 'google-scholar.svg',
      url_pattern: 'https://scholar.google.com/citations?user=XXX',
      placeholder: 'abcdEFGhiJKLMno',
      label: 'Google Scholar ID',
      default_position: 3,
      icon: 'icon-googlescholar',
      re: /^[0-9a-zA-Z.-]+$/
    },
    {
      tag: 'linkedin',
      # img: 'linkedin.jpg',
      url_pattern: 'https://www.linkedin.com/in/XXX',
      placeholder: 'john-doe-12345',
      label: 'Linkedin',
      default_position: 4,
      icon: 'linkedin',
      re: %r{^[a-z][a-z0-9-]+/?$}
    },
    {
      tag: 'github',
      # img: 'github.png',
      url_pattern: 'https://github.com/XXX',
      placeholder: 'username',
      label: 'GitHub',
      default_position: 5,
      icon: 'github',
      re: /^[A-Za-z0-9_.-]+$/
    },
    # {
    #   tag: 'stack_overflow',
    #   # img: 'stack-overflow.svg',
    #   url_pattern: 'https://stackoverflow.com/users/XXX',
    #   placeholder: '12345678',
    #   label: 'Stack Overflow',
    #   default_position: 6,
    #   icon: 'icon-stackoverflow',
    #   re: /^[0-9]+$/
    # },
    # TODO: the mastodon address needs to be something like @instance@username
    #       and the URL have to be recomputed accordingly.
    #       Alternatively, we can limit to epfl instance social.epfl.ch
    {
      tag: 'mastodon',
      # img: 'mastodon.png',
      url_pattern: 'https://social.epfl.ch/@XXX',
      placeholder: 'username',
      label: 'Mastodon',
      automatic: true,
      default_position: 7,
      icon: 'icon-mastodon',
      re: /^[A-Za-z0-9_]+$/
    },
    {
      tag: 'bluesky',
      # img: 'mastodon.png',
      url_pattern: 'https://bsky.app/profile/XXX',
      placeholder: 'username',
      label: 'Bluesky',
      automatic: false,
      default_position: 8,
      icon: 'icon-bluesky',
      re: /^[A-Za-z0-9_]+$/
    }
    # {
    #   tag: 'facebook',
    #   # img: 'facebook.png',
    #   url_pattern: 'https://www.facebook.com/XXX',
    #   placeholder: 'john.doe',
    #   label: 'Facebook',
    #   default_position: 8,
    #   icon: 'icon-facebook',
    #   re: /^[A-Za-z0-9.]+$/
    # },
    # {
    #   tag: 'instagram',
    #   # img: 'instagram.png',
    #   url_pattern: 'https://www.instagram.com/XXX',
    #   placeholder: '@username',
    #   label: 'Instagram',
    #   default_position: 9,
    #   icon: 'instagram',
    #   re: /^[A-Za-z0-9._]+$/
    # },
    # {
    #   tag: 'muskidiocy',
    #   url_pattern: 'https://x.com/XXX',
    #   placeholder: 'username',
    #   label: 'X (Twitter)',
    #   default_position: 99,
    #   icon: 'icon-x',
    #   re: /^[A-Za-z0-9_]+$/
    # }
  ].freeze

  RESEARCH_IDS = RESEARCH_IDS_LIST.index_by { |v| v[:tag] }.freeze
  TAG_SELECT_OPTIONS = RESEARCH_IDS_LIST.map { |v| [v[:label], v[:tag]] }

  SPECS_DELEGATE_METHODS = %w[
    automatic help_on_empty help_url icon img label
    default_position placeholder re url_pattern
  ].freeze

  belongs_to :profile, class_name: "Profile", inverse_of: :socials

  before_validation :sanitize_value
  before_save :fetch_value, if: -> { automatic? }

  validates :value, presence: true, unless: -> { automatic? }
  validate :validate_format_of_value, unless: -> { automatic? }
  validate :url_actually_exists, unless: -> { automatic? }
  validates :tag, presence: true, uniqueness: { scope: :profile_id }, inclusion: { in: RESEARCH_IDS.keys }

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:position)
  end

  def self.tag?(tag)
    tag.present? && RESEARCH_IDS.key?(tag)
  end

  def self.remaining(list)
    available_tags = RESEARCH_IDS_LIST.map { |s| s[:tag] } - list.map(&:tag)
    available_tags.map { |t| RESEARCH_IDS[t] }
  end

  def automatic?
    automatic || false
  end

  def icon_class
    icon.nil? ? '' : "social-icon-#{icon}"
  end

  def specs
    @specs ||= Social.tag?(tag) ? OpenStruct.new(RESEARCH_IDS[tag]) : nil
  end

  def url
    v = value.presence || placeholder
    url_pattern&.sub('XXX', v)
  end

  def url_prefix
    url_pattern&.sub('XXX', '')
  end

  def value
    if automatic? && self[:value].blank?
      fetch_value
    else
      self[:value]
    end
  end

  SPECS_DELEGATE_METHODS.each do |m|
    define_method(m) do
      specs&.send(m.to_sym)
    end
  end

  private

  def sanitize_value
    return if value.blank?

    begin
      uri = URI.parse(value.strip)
      self.value = if uri.scheme && uri.host
                     %w[user authorId authorID].each do |param|
                       v = uri.query&.match(/#{param}=([^&]+)/)&.captures&.first
                       return self.value = v if v.present?
                     end
                     parts = uri.path.sub(%r{^/}, '').split('/')
                     parts.last.presence || value.strip
                   else
                     value.strip
                   end
    rescue URI::InvalidURIError
      self.value = value.strip
    end
  end

  def fetch_value
    m = "fetch_#{tag}"
    raise NotImplementedError unless respond_to?(m, :include_private)

    v = send(m)

    dir = persisted? && (self[:value] != v || updated_at < AUTO_MAX_AGE.ago)
    self.value = v
    save if dir
    v
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

  def sciper
    @sciper ||= profile.sciper
  end

  def fetch_orcid
    ldp = Ldap::Person.for_sciper(sciper)
    return nil? if ldp.blank?

    ldp.eduPersonOrcid&.sub("https://orcid.org/", "")
  end

  def fetch_mastodon
    ldp = Ldap::Person.for_sciper(sciper)
    return nil? if ldp.blank?

    uids = ldp.uid
    uid = uids.is_a?(Array) ? uids.first : uids
    uid.gsub(/^@.*$/, "")
  end
end
