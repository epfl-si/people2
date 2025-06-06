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
  HIDDEN = 4
  VISIBLE = 0
  WORLD = 0
  INTRANET = 1
  AUTENTICATED = 2
  OWNER = 3
  NOBPDY = 4
  ALL_VISIBILITY_OPTIONS = [
    { label: 'visible',  icon: 'eye',        value: 0, box: false, item: true, style: "full" },
    { label: 'public',   icon: 'globe',      value: 0, box: true,  item: false, style: "full" },
    { label: 'intranet', icon: 'icon-epfl-corporate-logo', value: 1, box: true, item: false, style: "partial" },
    { label: 'auth',     icon: 'user-check', value: 2, box: false, item: false, style: "partial" },
    { label: 'draft',    icon: 'edit-3',     value: 3, box: false, item: false, style: "none" },
    { label: 'hidden',   icon: 'eye-off',    value: 4, box: true, item: true, style: "none" }
  ].map { |h| OpenStruct.new(h) }.freeze
  BOX_VIS_OPTIONS  = ALL_VISIBILITY_OPTIONS.select(&:box)
  ITEM_VIS_OPTIONS = ALL_VISIBILITY_OPTIONS.select(&:item)

  BOX_VIS_OPTIONS_DICT = BOX_VIS_OPTIONS.index_by(&:value)
  ITEM_VIS_OPTIONS_DICT = ITEM_VIS_OPTIONS.index_by(&:value)

  extend ActiveSupport::Concern

  included do
    def self.audience_limit(strategy = nil)
      # Reminder: ranges do not include the upper limit
      # scope :world_visible, -> { where(visibility: 0) }
      # scope :intranet_visible, -> { where(visibility: 0...2) }
      # scope :auth_visible, -> { where(visibility: 0...3) }
      # scope :owner_visible, -> { where(visibility: 0...4) }
      strategy ||= (self <= Box ? :box : :item)
      scope :for_audience, ->(audience) { where(visibility: 0...(audience + 1)) }
      scope :visible, -> { where(visibility: VISIBLE) } if strategy == :item
      audience_limit_methods(strategy)
    end

    def self.audience_limit_property(property, strategy: :box)
      audience_limit_methods(strategy, property)
    end

    # TODO: this method cannot be called twice without property
    def self.audience_limit_methods(strategy, property = nil)
      visprefix = property.nil? ? "" : "#{property}_"
      vismethod = "#{visprefix}visibility"
      vismsym = vismethod.to_sym
      validates vismsym, numericality: { in: 0...5 }
      before_save -> { self[vismsym] = visibility_options.last.value if send(vismethod).blank? }
      case strategy
      when :box
        define_method("#{vismethod}_options") do
          BOX_VIS_OPTIONS
        end
        define_method("#{vismethod}_option") do
          BOX_VIS_OPTIONS_DICT[send(vismethod)]
        end
      when :item
        define_method("#{vismethod}_options") do
          ITEM_VIS_OPTIONS
        end
        define_method("#{vismethod}_option") do
          ITEM_VIS_OPTIONS_DICT[send(vismethod)]
        end
        define_method("#{visprefix}hidden?") do
          send("#{visprefix}visibility") >= HIDDEN
        end
        define_method("#{visprefix}visible?") do
          send("#{visprefix}visibility") == VISIBLE
        end
      else
        raise "Invalid strategy #{strategy}"
      end
      define_method("#{visprefix}visible_by?") do |level|
        send(vismethod) <= level
      end
      define_method("#{visprefix}hidden?") do
        send(vismethod) > 3
      end
    end
  end
end
