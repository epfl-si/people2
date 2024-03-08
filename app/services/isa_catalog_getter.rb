# frozen_string_literal: true

# curl https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants | jq
# ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants'" | jq
class IsaCatalogGetter < IsaService
  attr_reader :url

  def initialize(years = current_academic_year)
    @url = URI.join(Rails.application.config_for(:epflapi).isa_url, "/services/catalog/", years)
  end

  # Disable caching because file is too big and we will download it only
  # once per semester to populate the DB with local data for faster access
  def do_cache
    false
  end

  def current_academic_year
    d = Time.zone.today
    y = d.year
    if d.month < 8
      "#{y - 1}-#{y}"
    else
      "#{y}-#{y + 1}"
    end
  end
end
