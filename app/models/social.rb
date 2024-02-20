# frozen_string_literal: true

class Social < ApplicationRecord
  include AudienceLimitable

  RESEARCH_IDS = {
    # https://orcid.org/0000-0002-1825-0097
    'orcid' => {
      'img' => 'ORCIDiD_icon16x16.png',
      'url' => 'https://orcid.org/XXX',
      'label' => 'ORCID',
      'order' => 0,
      'icon' => nil,
      're' => /^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/,
      'help' => {
        'en' => 'https://orcid-integration.epfl.ch/',
        'fr' => 'https://orcid-integration.epfl.ch/'
      }
    },
    # https://www.webofscience.com/wos/author/rid/AAX-5119-2020
    'wos' => {
      'img' => 'publons.png',
      'url' => 'https://www.webofscience.com/wos/author/rid/XXX',
      'label' => 'Publons - Web of Science ID',
      'order' => 1,
      'icon' => nil,
      're' => /^([A-Z]+-[0-9]{4}-[0-9]{4}|[0-9])+$/
    },
    # https://www.scopus.com/authid/detail.uri?authorId=57192201516
    'scopus' => {
      'img' => 'scopus.png',
      'url' => 'https://www.scopus.com/authid/detail.uri?authorId=XXX',
      'label' => 'Scopus ID',
      'order' => 2,
      'icon' => nil,
      're' => /^[0-9]+$/
    },
    'googlescholar' => {
      'img' => 'google_scholar.png',
      'url' => 'https://scholar.google.com/citations?user=XXX&hl=en&oi=ao',
      # 'url' => "https://scholar.google.com/citations?user=XXX"
      'label' => 'Google Scholar ID',
      'order' => 3,
      'icon' => 'google',
      're' => /^[0-9a-zA-Z.-]+$/ # TODO: check this!
    },
    'linkedin' => {
      'img' => 'linkedin.jpg',
      'url' => 'https://www.linkedin.com/in/XXX',
      'label' => 'Linkedin ID',
      'order' => 4,
      'icon' => 'linkedin',
      're' => %r{^[a-z][a-z0-9-]+/?$} # TODO: check this!
    },
    # https://github.com/XXX
    'github' => {
      'img' => 'github.png',
      'url' => 'https://github.com/XXX',
      'label' => 'GitHub',
      'order' => 5,
      'icon' => 'github',
      're' => /^[A-Za-z0-9_.-]+$/,
    },
    # TODO: stack overflow, mastodon, facebook, twitter, instagram, ...
  }.freeze

  belongs_to :profile, class_name: "Profile", inverse_of: :socials

  validates :value, presence: true
  validates :tag, presence: true
  validates :tag, inclusion: { in: RESEARCH_IDS.keys }
  validate :validate_format_of_value

  before_save :ensure_sciper

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:order)
  end

  def url
    @url ||= begin
      @s = RESEARCH_IDS[tag]
      @s['url'].sub('XXX', content)
    end
  end

  def icon_class
    @s ||= RESEARCH_IDS[tag]
    @s['icon'].nil? ? '' : "social-icon-#{@s['icon']}"
  end

  def icon
    @s ||= RESEARCH_IDS[tag]
    @s['icon']
  end

  def image
    @s ||= RESEARCH_IDS[tag]
    "social/#{@s['img']}"
  end

  def label
    @s ||= RESEARCH_IDS[tag]
    @s['label']
  end

  def default_order
    @s ||= RESEARCH_IDS[tag]
    @s['order']
  end

  private

  # we call this before save so that profile is present due to passed validation
  def ensure_sciper
    sciper || profile.sciper
  end

  def validate_format_of_value
    unless RESEARCH_IDS.key?(tag)
      errors.add(:tag, "Invalid social network name/tag")
      return false
    end
    re = RESEARCH_IDS[tag]['re']
    unless re.match?(value)
      errors.add(:value, "incorrect format")
      return false
    end
    true
  end
end
