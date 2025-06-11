# frozen_string_literal: true

require 'net/http'
require 'base64'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :legacy do
  desc 'Refresh adoptions: delete all adoption records and reload them'
  task refresh_adoptions: %i[nuke_adoptions adoptions] do
  end

  desc 'Nuke adoptions'
  task nuke_adoptions: :environment do
    c = Adoption.count
    puts "Deleting #{c} adoptions..."
    Adoption.in_batches(of: 1000).delete_all
    puts "Done deleting adoptions"
  end

  desc 'Add missing adoptions from the list of scipers that are eligible to have a people account'
  task adoptions: :environment do
    migranda = Work::Sciper.migranda.pluck(:sciper)
    puts "Migranda count:        #{migranda.count}"
    done = Adoption.all.pluck(:sciper)
    puts "Adoption count before: #{done.count}"
    scipers_todo = migranda - done
    puts "Remaining to create:   #{scipers_todo.count}"
    data = []
    scipers_todo.in_groups_of(200).each do |ss|
      data = Work::Sciper.where(sciper: ss).map do |s|
        {
          accepted: false,
          email: s.email,
          fullname: s.name
        }
      end
      # rubocop:disable Rails/SkipsModelValidations
      Adoption.insert_all(data)
      # rubocop:enable Rails/SkipsModelValidations
    end
    puts "Adoption count after:  #{Adoption.count}"
  end
end
