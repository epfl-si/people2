# frozen_string_literal: true

class UsualNameChange < ApplicationRecord
  belongs_to :profile
  before_validation :ensure_new_names
  after_create :sync_with_source
  validates :official_first, presence: true
  validates :official_last, presence: true
  validate :first_is_compatible_with_official
  validate :last_is_compatible_with_official

  # Return nil if profile is not allowed to change usual name the automatic way
  def self.for(profile)
    name = profile.name
    return nil unless name.customizable?

    new(
      old_first: name.usual_first || name.official_first,
      old_last: name.usual_last || name.official_last,
      official_first: name.official_first,
      official_last: name.official_last,
      profile: profile
    )
  end

  private

  def compatible?(n, o)
    nn = n.split(/\s+/)
    oo = o.split(/\s+/)
    nn.all? { |t| oo.include?(t) }
  end

  def first_is_compatible_with_official
    new_first.nil? || compatible?(new_first, official_first) || errors.add(:new_first, :invalid_format)
  end

  def last_is_compatible_with_official
    new_last.nil? || compatible?(new_last, official_last) || errors.add(:new_last, :invalid_format)
  end

  def ensure_new_names
    self.new_first = official_first if new_first.blank?
    self.new_last = official_last if new_last.blank?
  end

  def sync_with_source
    ProfilePatchJob.perform_later("sciper" => profile.sciper, "firstnameusual" => new_first,
                                  "lastnameusual" => new_last)
  end
end
