# frozen_string_literal: true

namespace :data do
  desc 'Destroy all the entries for Phd'
  task nuke_phds: %(environment) do
    Phd.in_batches(of: 1000).destroy_all
  end

  desc 'Refresh courses for new semester'
  task refresh_current_phds: %i[environment] do
    PhdsImporterJob.perform_now
  end

  desc 'Import all present and past Phds'
  task import_phds: %i[environment] do
    # 1994 is the first year with PhD data in Oasis
    1994.upto(Time.zone.now.year).each do |y|
      PhdsImporterJob.perform_now(y)
    end
  end
end
