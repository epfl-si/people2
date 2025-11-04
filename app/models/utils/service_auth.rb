# frozen_string_literal: true

module Utils
  class ServiceAuth < ApplicationRecord
    validates :service, presence: true

    def self.check(service, request, params)
      where(service: service).any? { |c| c.check(request, params) }
    end
  end
end
