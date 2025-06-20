# frozen_string_literal: true

# This could be nicely implemented as enum but it is not yet implemented for mysql
# audience: 0=world, 1=intranet, 2=authenticated user
# visibility: 0=public, 1=draft, 2=hidden
# TODO: write unit tests
# TODO: when importing legacy data:
#       - visible => audience=0, visibility=0
#       - hidden  => audience=0, visibility=2

module AudienceLimitable
  # label: is used for translations
  # icon:  the icon to used to indicate the status
  # value: the integer value stored in the database
  # box:   if this option is available for boxes
  # item:  if this option is available for items in index boxes or other elements
  VISIBLE = 0
  HIDDEN = 4

  WORLD = 0
  INTRANET = 1
  AUTENTICATED = 2
  OWNER = 3
  NOBODY = 4

  ALL_VISIBILITY_OPTIONS = {
    visibility: [
      { label: 'visible', value: 0, next: 4, lit: true,  style: "full", icon: 'eye' },
      { label: 'hidden',  value: 4, next: 0, lit: false, style: "none", icon: 'eye-off' }
    ].map { |h| OpenStruct.new(h) },
    toggle: [
      { label: 'enabled',  value: 0, next: 4, lit: true,  style: "full", icon: 'thumbs-up' },
      { label: 'disabled', value: 4, next: 0, lit: false, style: "none", icon: 'thumbs-down' }
    ].map { |h| OpenStruct.new(h) },
    audience: [
      { label: 'public',   value: 0, next: 1, lit: true,  style: "full",    icon: 'globe' },
      { label: 'intranet', value: 1, next: 4, lit: true,  style: "partial", icon: 'icon-epfl-corporate-logo' },
      # { label: 'auth',     value: 2, next: 3, lit: true,  style: "partial", icon: 'user-check' },
      # { label: 'draft',    value: 3, next: 4, lit: true,  style: "none",    icon: 'edit-3' },
      { label: 'hidden',   value: 4, next: 0, lit: false, style: "none",    icon: 'eye-off' }
    ].map { |h| OpenStruct.new(h) }
  }.freeze

  extend ActiveSupport::Concern

  included do
    def self.audience_limit(strategy = nil, default: VISIBLE)
      # Reminder: ranges do not include the upper limit
      # scope :world_visible, -> { where(visibility: 0) }
      # scope :intranet_visible, -> { where(visibility: 0...2) }
      # scope :auth_visible, -> { where(visibility: 0...3) }
      # scope :owner_visible, -> { where(visibility: 0...4) }
      strategy ||= (self <= Box ? :audience : :toggle)
      scope :for_audience, ->(audience) { where(visibility: 0...(audience + 1)) }
      scope :visible, -> { where(visibility: VISIBLE) } if strategy == :item
      audience_limit_methods(strategy, default: default)
    end

    def self.audience_limit_property(property, strategy: :audience, default: VISIBLE)
      audience_limit_methods(strategy, property, default: default)
    end

    # TODO: this method cannot be called twice without property
    def self.audience_limit_methods(strategy, property = nil, default: VISIBLE)
      visprefix = property.nil? ? "" : "#{property}_"
      vismethod = "#{visprefix}visibility"
      vismsym = vismethod.to_sym
      validates vismsym, numericality: { in: 0...5 }
      before_validation -> { self[vismsym] = default if send(vismethod).blank? }

      opts = ALL_VISIBILITY_OPTIONS[strategy]
      opts_dict = opts.index_by(&:value)
      validates vismsym, inclusion: opts.map(&:value)

      # box.visibility_options
      # accred.address_visibility_options
      # return the list of VISIBILITY_OPTIONS for the current strategy
      define_method("#{vismethod}_options") do
        opts
      end

      # box.visibility_option
      # accred.address_visibility_option
      # return the VISIBILITY_OPTION for the current strategy and visibility
      define_method("#{vismethod}_option") do
        opts_dict[send(vismethod)]
      end

      # box.visible_by?(audience)
      define_method("#{visprefix}visible_by?") do |level|
        send(vismethod) <= level
      end

      # defines sortcut methods like the following (not sure if of any use)
      #   accred.public?
      #   box.intranet?
      #   accred.address_visible?
      #   item.enabled?
      opts.each do |o|
        define_method("#{visprefix}#{o.label}?") do
          send("#{visprefix}visibility") == o.value
        end
      end

      # may override the .hidden? or property_hidden? method defined above
      define_method("#{visprefix}hidden?") do
        send(vismethod) >= NOBODY
      end
    end
  end
end
