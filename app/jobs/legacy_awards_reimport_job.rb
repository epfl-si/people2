# frozen_string_literal: true

class LegacyAwardsReimportJob < ApplicationJob
  queue_as :default
  # Import awards for already existing profiles that still have empty list of awards
  def perform(dryrun: false)
    # invalids=[]
    laa = Legacy::Award.where(sciper: Work::Sciper.migranda.pluck(:sciper))
    # scipers of existing profiles
    pss = Profile.pluck(:sciper)
    # legacy and new awards scipers
    lss = laa.map(&:sciper).uniq.intersection(pss)
    nss = Award.joins(:profile).map(&:sciper).uniq
    # scipers that we have to treat
    ss = lss - nss
    ss.each do |s|
      pro = Profile.for_sciper(s)
      Legacy::Award.where(sciper: s).find_each do |la|
        a = la.to_award('en', profile: pro, fallback_lang: 'en')
        if dryrun ? a.valid? : a.save
          Rails.logger.debug "Legacy::Award OK #{s}/#{la.ordre}"
          next
        end
        errs = a.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
        invalids << la
        Rails.logger.error "Legacy::Award ERR #{s}/#{la.ordre}: #{errs}"
      end
    end
    # # Rails.logger.error "Legacy::Award Invalids: #{invalids.to_json}"
    # File.open('tmp/bad_awards.csv', 'w+') do |f|
    #   headers = ["id", "sciper", "name", "year", "category", "origin", "title", "grantedby", "url"]
    #   f.puts CSV.generate_line headers
    #   invalids.each do |ia|
    #     per=Person.find(ia.sciper)
    #     f.puts CSV.generate_line([
    #       ia.id, ia.sciper, per.name.display, ia.year, ia.category, ia.origin, ia.title, ia.grantedby, ia.url
    #     ])
    #   end
    # end
    nil
  end
end
