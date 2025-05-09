# frozen_string_literal: true

class Publication < ApplicationRecord
  include AudienceLimitable
  include Translatable
  include IndexBoxable
  belongs_to :profile
  audience_limit
  positioned on: :profile

  validates :title, presence: true
  validates :year, numericality: { only_integer: true, allow_nil: true }
  validates :url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
end
