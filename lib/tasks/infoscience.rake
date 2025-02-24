# frozen_string_literal: true

require 'csv'
namespace :legacy do
  desc 'Export invalid infoscience links for Julien to look with library'
  task infoscience_for_julien: :environment do
    scipers = Work::Sciper.with_profile.map(&:sciper)
    boxes = Legacy::Infoscience
            .with_source
            .where.not("src LIKE '%infoscience-export%'")
            # .where.not("src LIKE '%infoscience.epfl.ch/record%'")
            .where(sciper: scipers)
            .where(box_show: 1)
            .order(:sciper)
    puts "There are #{boxes.count} infoscience boxes to be imported"
    opath = Rails.root.join("tmp/infoscience")
    opath.mkdir unless opath.directory?
    data = boxes.map do |b|
      res = {}
      res['sciper'] = b.sciper.to_i
      res['src'] = b.src
      res['lang'] = b.cvlang
      if b.content.present?
        res['cache'] = "#{b.sciper}_#{b.cvlang}.html"
        ofile = opath.join(res['cache'])
        File.open(ofile, 'w+') do |f|
          f.puts b.content
        end
      else
        res['cache'] = 'NONE'
      end
      res
    end
    File.open(opath.join("index.yml"), 'w+') do |f|
      f.puts data.to_yaml
    end
    csvstring = CSV.generate do |csv|
      csv << data.first.keys
      data.each do |b|
        csv << b.values
      end
    end
    File.open(opath.join("index.csv"), 'w+') do |f|
      f.puts csvstring
    end
  end
end
