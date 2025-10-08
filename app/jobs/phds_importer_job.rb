# frozen_string_literal: true

class PhdsImporterJob < ApplicationJob
  queue_as :default

  def perform(year = nil)
    # If year is not provided, we take the current year and consider this as a
    # periodic refresher for current students. We take a wider range of years
    # for existing so that we are sure that we do not duplicate records
    if year.nil?
      year = Time.zone.now.year
      existing = Phd.recent.index_by(&:sciper)
    else
      existing = Phd.where(year: year).index_by(&:sciper)
    end
    ophds = OasisPhdGetter.call(year: year) + OasisPhdGetter.call(year: year, alumni: true)
    ophds.sort { |a, b| a.sciper <=> b.sciper }.uniq.each_slice(50) do |ophds|
      scipers = ophds.map(&:sciper).compact
      peos = BulkPerson.for_scipers(scipers).index_by(&:sciper)
      ophds.each do |ophd|
        phd = ophd.updated_phd(phd: existing[ophd.sciper], year: year)
        n = peos[ophd.sciper]&.name&.display
        phd.name = n if n.present?
        phd.save
      end
    end
    nil
  end
end
