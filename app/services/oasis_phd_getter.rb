# frozen_string_literal: true

class OasisPhdGetter < OasisBaseGetter
  def initialize(data = {})
    current_year = Time.zone.today.year
    @year = data[:year]&.to_i || current_year
    @url = if @year == current_year
             URI.join(baseurl, "/etudiants/phd")
           else
             URI.join(baseurl, "/alumni/doctors/#{@year}")
           end
    @model = Oasis::Phd
  end
end
