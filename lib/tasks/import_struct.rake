# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s

# The following list is taken from the server access logs
# USED_STRUCTS = [
#  "default_en_struct",
#  "default_struct",
#  "AE-fr",
#  "AE_en",
#  "AE_en2024",
#  "ICLAB",
#  "LHTC_Admin_en",
#  "topo_struct_en2",
#  "turcopoly_default_str",
#  "default_en_struct_LA",
#  "img",
#  "DQMLstr",
#  "AE",
#  "DESL-PWRS_struct",
#  "LMIS1_struct",
#  "LBMM_list_struct",
#  "default_simple",
#  "IC-TMLlab",
#  "LMIS2_en.struct",
#  "lis_struct_en",
#  "AE-en",
#  "create_lab_structure",
# ]

# Subset of the previous list that do have a corresponding file
USED_STRUCTS = [
  "AE",
  "AE_en2024",
  "DESL-PWRS_struct",
  "IC-TMLlab",
  "ICLAB",
  "LBMM_list_struct",
  "LHTC_Admin_en",
  "LMIS1_struct",
  "LMIS2_en.struct",
  "default_en_struct",
  "default_en_struct_LA",
  "default_struct",
  "lis_struct_en",
  "topo_struct_en2",
  "turcopoly_default_str"
].freeze

namespace :legacy do
  desc 'Import legacy struct files content'
  task struct: :environment do
    strdir = Rails.root.join("tmp/structs")
    unless strdir.exist?
      puts "Please rsync the struct files from /var/www/vhosts/people.epfl.ch/private/tmpl/tromb into #{strdir}"
    end
    as = []
    to = []
    fn = strdir.join(".owners.txt")
    fn.open("r:ISO-8859-1:UTF-8") do |io|
      io.readlines.each do |l|
        begin
          k, os = Legacy.deshit(l.chomp).split(/\t+/)
        rescue StandardError
          puts "Skipping unparseable line: #{l}"
          next
        end
        next unless k.present? && os.present?

        # TODO: keep only scipers of existing people
        oo = os.split(",").map { |s| s.gsub(/:.*/, "") }.select { |s| s =~ /^\d{6}$/ }
        as += oo
        to << [k, oo]
      end
    end
    ss = Work::Sciper.where(sciper: as.uniq).map { |s| [s.sciper, s.status] }.to_h
    owners = {}
    to.each do |k, oo|
      owners[k] = oo.filter { |s| (ss[s] || 0) > 1 }
    end
    USED_STRUCTS.each do |k|
      fn = strdir.join(k)
      next unless fn.exist?

      puts "Parsing #{k}"
      data = []
      fn.open("r:ISO-8859-1:UTF-8") do |io|
        io.readlines.each do |l|
          t, f = Legacy.deshit(l.chomp).split(/\t+/)
          data << {
            title: t,
            filter: f.gsub(/\s*,\s*/, ' or ')
          }
        end
      end
      stru = Structure.new(
        label: k,
        description: "Imported from Legacy"
      )
      stru.data = data
      stru.owners = owners[k].join(",") if owners[k].present?
      stru.save
    end
  end
end
