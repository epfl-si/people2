# frozen_string_literal: true

class Redirect < ApplicationRecord
  def self.for_sciper_or_name(v)
    s = v.is_a?(Integer) || v =~ /^\d{6}$/ ? { sciper: v } : { ns: v }
    where(s).first
  end
end
