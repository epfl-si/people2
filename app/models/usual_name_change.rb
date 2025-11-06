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
  def self.for(profile, name, params = { new_first: nil, new_last: nil })
    return nil unless name.customizable?

    new(
      official_first: name.official_first,
      official_last: name.official_last,
      old_first: name.display_first,
      old_last: name.display_last,
      new_first: params[:new_first],
      new_last: params[:new_last],
      profile: profile
    )
  end

  def useless?
    new_first == old_first && new_last == old_last
  end

  def done?
    new_first == profile.name.display_first && new_first == profile.name.display_last
  end

  def retriable?
    (Time.zone.now - created_at) > 2.days
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
    Rails.logger.debug("ProfilePatchJob with sciper: #{profile.sciper}  first: #{new_first}  last: #{new_last}")
    ProfilePatchJob.perform_later(
      sciper: profile.sciper,
      firstname: new_first,
      lastname: new_last
    )
  end
end
