# frozen_string_literal: true

class Option < ApplicationRecord
  serialize :data, coder: YAML
  KINDS = %i[redirect email].freeze
  KIND_IDS = KINDS.each_with_index.to_h
  def self.for(sciper)
    where(sciper: sciper).map { |r| [KINDS[r.kind], r.data] }.to_h
  end
end
