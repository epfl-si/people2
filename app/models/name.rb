# frozen_string_literal: true

class Name
  attr_accessor :id, :usual_first, :usual_last, :official_first, :official_last

  include ActiveModel::API
  extend ActiveModel::Naming

  validate :usual_names_are_taken_from_official

  def complete?
    official_first.present? && official_last.present?
  end

  def display_first
    usual_first
  end

  def display_last
    usual_last
  end

  def display
    "#{display_first} #{display_last}"
  end

  def official_display
    complete? ? "#{official_first} #{official_last}" : "NA"
  end

  def tokens_first
    official_first&.split(/\W+/) || []
  end

  def tokens_last
    official_last&.split(/\W+/) || []
  end

  def suggested_first
    tokens_first.first
  end

  def suggested_last
    tokens_last.first
  end

  def customizable?
    complete? && (customizable_first? || customizable_last?)
  end

  def customizable_first?
    tokens_first.count > 1
  end

  def customizable_last?
    tokens_last.count > 1
  end

  def usual_names_are_taken_from_official
    return unless complete?

    errors.add(:usual_first, :not_in_official) unless compatible_names(official_first, usual_first)
    errors.add(:usual_last, :not_in_official) unless compatible_names(official_last, usual_last)
  end

  private

  def compatible_names?(o, u)
    return false if o.blank?

    oa = o.split(/\W+/)
    ua = u.split(/\W+/)
    # return false unless (ua - oa).empty?

    oh = Hash.new 0
    oa.each { |w| oh[w] += 1 }
    uh = Hash.new 0
    ua.each { |w| uh[w] += 1 }
    uh.each do |w, c|
      oc = oh[w] || 0
      return false if (oc - c).negative?
    end
    true
  end
end
