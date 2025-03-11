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
  ALL_VISIBILITY_OPTIONS = [
    { label: 'visible',  icon: 'eye',        value: 0, box: false, item: true },
    { label: 'public',   icon: 'globe',      value: 0, box: true,  item: false },
    { label: 'intranet', icon: 'home',       value: 1, box: true,  item: false },
    { label: 'auth',     icon: 'user-check', value: 2, box: false, item: false },
    { label: 'draft',    icon: 'edit-3',     value: 3, box: true,  item: false },
    { label: 'hidden',   icon: 'eye-off',    value: 4, box: true,  item: true }
  ].map { |h| OpenStruct.new(h) }.freeze
  BOX_VIS_OPTIONS  = ALL_VISIBILITY_OPTIONS.select(&:box)
  ITEM_VIS_OPTIONS = ALL_VISIBILITY_OPTIONS.select(&:item)

  BOX_VIS_OPTIONS_DICT = BOX_VIS_OPTIONS.index_by(&:value)
  ITEM_VIS_OPTIONS_DICT = ITEM_VIS_OPTIONS.index_by(&:value)

  extend ActiveSupport::Concern

  included do
    # Reminder: ranges do not include the upper limit
    scope :world_visible, -> { where(visibility: 0) }
    scope :intranet_visible, -> { where(visibility: 0...2) }
    scope :auth_visible, -> { where(visibility: 0...3) }
    scope :owner_visible, -> { where(visibility: 0...4) }
    scope :for_audience, ->(audience) { where(visibility: 0...(audience + 1)) }
    validates :visibility, numericality: { in: 0...5 }

    if self <= Box
      def visibility_options
        BOX_VIS_OPTIONS
      end

      def visibility_option
        BOX_VIS_OPTIONS_DICT[visibility]
      end
    else
      def visibility_options
        ITEM_VIS_OPTIONS
      end

      def visibility_option
        ITEM_VIS_OPTIONS_DICT[visibility]
      end
    end
  end

  def visible_by?(level = 0)
    visibility <= level
  end

  def world_visible?
    visibilty.zero?
  end

  def intranet_visible?
    visibilty < 2
  end

  def auth_visible?
    visibilty < 3
  end

  def owner_visible?
    visibility < 4
  end

  def hidden?
    visibility > 3
  end
end
