# frozen_string_literal: true

class Publication < ApplicationRecord
  include AudienceLimitable
  include Translatable
  include IndexBoxable
  include Versionable
  belongs_to :profile
  audience_limit
  positioned on: :profile

  validates :title, presence: true
  validates :year, numericality: { only_integer: true, allow_nil: true }
  validates :url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true, length: { maximum: 1024 }
  validates :journal, presence: true, length: { maximum: 1024 }
end
