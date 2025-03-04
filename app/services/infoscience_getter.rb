# frozen_string_literal: true

class InfoscienceGetter < ApplicationService
  attr_reader :url

  def initialize(data = {})
    url = data[:url]
    raise "url parameter is mandatory for InfoscienceGetter" if url.blank?

    @url = URI.parse(url)
  end

  def dofetch
    fetch_http
  end
end
