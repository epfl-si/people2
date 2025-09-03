# frozen_string_literal: true

class PhdsImporterJob < ApplicationJob
  queue_as :default

  def perform(year)
    # Fetch all course codes for the academic year
    existing = Phd.where(year: year).index_by(&:sciper)
    OasisPhdGetter.call(year: year).sort { |a, b| a.sciper <=> b.sciper }.each_slice(50) do |ophds|
      scipers = ophds.map(&:sciper).compact
      peos = Person.for_scipers(scipers).index_by(&:sciper)
      ophds.each do |ophd|
        phd = ophd.updated_phd(phd: existing[ophd.sciper], year: year)
        n = peos[ophd.sciper]&.name&.display
        phd.name if n.present?
        phd.save
      end
    end
    nil
  end
end
