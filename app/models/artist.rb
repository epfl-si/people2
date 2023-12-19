# frozen_string_literal: true

class Artist < ApplicationRecord
  has_many :items, dependent: :destroy
end
