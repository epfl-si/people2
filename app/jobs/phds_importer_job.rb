# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class PhdsImporterJob < ApplicationJob
  queue_as :default

  def perform(year = nil)
    # If year is not provided, we take the current year and consider this as a
    # periodic refresher for current students. We take a wider range of years
    # for existing so that we are sure that we do not duplicate records

    year ||= Time.zone.today.year
    recent = 5.years.ago.year
    existing = year > recent ? Phd.where("year > #{recent}") : Phd.where(year: year)
    existing_by_sciper = existing.index_by(&:sciper)

    ophds = OasisPhdGetter.call(year: year, alumni: true).index_by(&:sciper)
    scipers = ophds.keys

    # Create alumni Phds and set all found in Oasis as alumni
    missing_scipers = (scipers - existing_by_sciper.keys)
    create_with_person(missing_scipers, ophds, year, past: true)
    Phd.where(sciper: scipers).where('year < ?', year).update_all(year: year)
    Phd.where(sciper: scipers).update_all(past: true)

    return if year < Time.zone.today.year

    # The current year there might also be active Phd students
    ophds = OasisPhdGetter.call(year: year).index_by(&:sciper)
    scipers = ophds.keys
    missing_scipers = (scipers - existing_by_sciper.keys)
    create_with_person(missing_scipers, ophds, year, past: false)
    Phd.where(sciper: scipers).where('year < ?', year).update_all(year: year)
    Phd.where(sciper: scipers).update_all(past: false)
  end

  def create_with_person(missing_scipers, ophds, year, past: false)
    return if missing_scipers.empty?

    missing_scipers.uniq.each_slice(50) do |scipers|
      # BulkPerson requires an accreditation to exist. Old Phds most of the time
      # only exist in the ISA database but not in accred. We are interested only
      # in the display name. Therefore we skip Person & BulkPerson
      # bpp = BulkPerson.for_scipers(scipers, filterbotweb: false).index_by(&:sciper)
      names = APIPersonGetter.call(persid: scipers, single: false)&.map do |v|
        [v["id"], "#{v['firstname']} #{v['lastname']}"]
      end.to_h || {}
      scipers.each do |sciper|
        ophd = ophds[sciper]
        phd = ophd.updated_phd(year: year)
        phd.past = past
        n = names[sciper]
        if n.present?
          phd.name = n
          phd.save
        else
          Rails.logger.warn "Missing Person for Phd with sciper #{sciper}"
        end
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
