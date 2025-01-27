# frozen_string_literal: true

class SpecialOption < ApplicationRecord
  serialize :data, coder: YAML

  scope :for, ->(sciper) { where(sciper: sciper) }

  def self.for_sciper_or_name(v)
    s = v.is_a?(Integer) || v =~ /^\d{6}$/ ? { sciper: v } : { ns: v }
    where(s)
  end

  def key
    self.class.name.gsub(/^Special/, '').downcase.to_sym
  end
end
