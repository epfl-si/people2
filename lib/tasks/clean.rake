# frozen_string_literal: true

# Implement `./bin/rake devel:clean` and `./bin/rake devel:realclean`

namespace :data do
  desc 'Delete all user-related records. This is only meant for the very first deployment in production!!!!!!'
  task hiroshima_and_nagasaki: :environment do
    $stdout.puts "This is going to nuke all the profiles-relate data. Are you sure? (y/n)"
    input = $stdin.gets.strip
    if input == 'y'
      $stdout.puts "Please enter the password to confirm"
      input = $stdin.gets.strip
      pass = BCrypt::Password.new("$2a$18$y41NDScNy7nuQWbM.U3eROwJGQplQNVYG3zvwpRBRQEi7ecXI/8Sy")
      if pass == input
        $stdout.puts "Ok. Are you really really sure? (y/n)"
        input = $stdin.gets.strip
        if input == 'y'
          Work::Version.in_batches(of: 1000).delete_all
          Profile.in_batches(of: 100).destroy_all
        end
      end
    end
  end
end

namespace :devel do
  desc 'Delete all generated files'
  task clean: :environment do
    Dir.chdir(Rails.root)
    Rake::Task['javascript:clobber'].invoke

    ['node_modules', 'vendor/bundle'].each do |dir|
      FileUtils.remove_dir(dir) if File.exist?(dir)
    end

    Rake::Task['tmp:clear'].invoke
    (['tmp/development_secret.txt', 'tmp/restart.txt'] +
     Dir.glob('app/assets/builds/*')).each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  desc "Delete gen'd files and the test databases"
  task realclean: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['devel:clean'].invoke
  end
end
