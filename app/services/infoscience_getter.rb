class InfoscienceGetter < ApplicationService
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def fetch
    fetch_http
  end
end
