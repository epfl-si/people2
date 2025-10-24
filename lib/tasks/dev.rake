# frozen_string_literal: true

# Not very usefull attempt to
namespace :dev do
  task check_indexes: :environment do
    [Work::Sciper, Profile, Legacy::Cv].each do |klass|
      conn = klass.send(:connection)
      conn.tables.each do |table|
        fk_cols = conn.foreign_keys(table).map(&:column)
        idx_cols = conn.indexes(table).flat_map(&:columns)
        missing = fk_cols - idx_cols
        puts "#{klass}/#{table}: No index for #{missing.join(', ')}" if missing.any?
      end
    end
  end
end
