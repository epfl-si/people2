# frozen_string_literal: true

class SpecialOption < ApplicationRecord
  serialize :data, coder: YAML
  before_validation :ensure_identifiers

  validates :sciper, presence: true
  validates :ns, presence: true
  validates :type, uniqueness: { scope: :sciper }

  def self.for_sciper_or_name(v)
    if v.is_a?(Integer) || v =~ /^\d{6}$/
      find_by(sciper: v)
    else
      find_by(ns: v)
    end
  end

  def key
    self.class.name.gsub(/^Special/, '').downcase.to_sym
  end

  # NOTE: since these are vary rare cases that almost never change, I wanted to
  # avoid to load from the DB at each request or, even worse, for each profile
  # The idea was to momoize the class variable for the lifetime of the application
  # and refresh it with an after_save callback. The problem is that this won't
  # work with multiple app instances as in production.
  # Therefore, for the moment I do it request-wide so that we avoid repeating
  # the request foreach profile when we have many (e.g. wsgetpeople). Probably
  # useless because AR might already detect repeated requests.
  # Another alternative is to add a `has_special_options` column in the profile
  # so we avoid the request that we know will return empty. This would mean that
  # only people aligible to have a profile can have special options which is not
  # the case with the current implementation.
  # @all_options ||= all.group_by(&:sciper)
  # @all_options[sciper.to_s]
  def self.for(sciper)
    Current.special_options ||= all.group_by(&:sciper)
    Current.special_options[sciper.to_s]
  end

  def display_name
    ns.split(/[.-]/).map(&:capitalize).join(" ")
  end

  private

  def ensure_identifiers
    return false if sciper.blank? && ns.blank?

    begin
      p = Person.find(sciper || ns)
    rescue ActiveRecord::RecordNotFound
      return false
    end

    self.ns = p.slug
    self.sciper = p.sciper
    true
  end
end
