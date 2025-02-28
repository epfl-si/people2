# frozen_string_literal: true

class SpecialOption < ApplicationRecord
  serialize :data, coder: YAML

  def self.for_sciper_or_name(v)
    s = v.is_a?(Integer) || v =~ /^\d{6}$/ ? { sciper: v } : { ns: v }
    where(s)
  end

  def key
    self.class.name.gsub(/^Special/, '').downcase.to_sym
  end

  # TODO: should we reload after save ?
  def self.for(sciper)
    @all_options ||= all.group_by(&:sciper)
    @all_options[sciper]
  end
end
