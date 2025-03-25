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
  AUTO_MAX_AGE = 180.days
  RESEARCH_IDS_LIST = [
    {
      tag: 'orcid',
      # img: 'ORCIDiD_icon16x16.png',
      url: 'https://orcid.org/XXX',
      placeholder: '0000-0002-5489-2425',
      label: 'ORCID',
      automatic: true,
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
      placeholder: '23049566200',
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
      automatic: true,
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

  before_save :fetch_value, if: -> { automatic? }

  validates :value, presence: true, unless: -> { automatic? }
  validate :validate_format_of_value, unless: -> { automatic? }
  validate :url_actually_exists, unless: -> { automatic? }
  validates :tag, presence: true, uniqueness: true, inclusion: { in: RESEARCH_IDS.keys }

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
    specs&.automatic || false
  end

  def specs
    @specs ||= Social.tag?(tag) ? OpenStruct.new(RESEARCH_IDS[tag]) : nil
  end

  def url
    specs&.url&.sub('XXX', value)
  end

  def icon_class
    icon.nil? ? '' : "social-icon-#{icon}"
  end

  def icon
    specs&.icon
  end

  def image
    specs&.img
  end

  def label
    specs&.label
  end

  def url_prefix
    url&.gsub('XXX', '')
  end

  def default_position
    specs&.position
  end

  def value
    if automatic? && self[:value].blank?
      fetch_value
    else
      self[:value]
    end
  end

  private

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
