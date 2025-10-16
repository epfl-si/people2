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
        Rails.logger.error "Legacy::Award ERR #{s}/#{la.ordre}: #{errs}"
      end
    end
    nil
  end
end

# # This was done to export a csv file for manual revision
# require 'csv'
# laa = Legacy::Award.where(sciper: Work::Sciper.migranda.pluck(:sciper))
# # scipers of existing profiles
# pss = Profile.pluck(:sciper)
# # legacy and new awards scipers
# lss = laa.map(&:sciper).uniq.intersection(pss)
# nss = Award.joins(:profile).map(&:sciper).uniq
# # scipers that we have to treat
# ss = lss - nss
# bad = []
# ss.each do |s|
#   pro = Profile.for_sciper(s)
#   Legacy::Award.where(sciper: s).find_each do |la|
#     a = la.to_award('en', profile: pro, fallback_lang: 'en')
#     bad << la unless a.valid?
#   end
# end
# puts "#{bad.count} still invalid"
# File.open('tmp/aaa.csv', 'w+') do |f|
#   headers = ["id", "sciper", "year", "category", "origin", "grantedby", "title", "url"]
#   f.puts CSV.generate_line headers
#   bad.each do |a|
#     f.puts CSV.generate_line [a.id, a.sciper, a.year, a.category, a.origin, a.grantedby, a.title, a.url]
#   end
# end
# # once fixed:
# d=CSV.read('tmp/aaa.csv')
# File.open("tmp/aaa.sql", 'w+') do |f|
#   d[1..].each do |l|
#     f.puts "update awards set category='#{l[3]}', origin='#{l[4]}' where id=#{l[0]}"
#   end
# end
# # tmp/aaa.sql sent to the legacy prod DB
