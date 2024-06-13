# frozen_string_literal: true

# stolen from https://gist.github.com/muxcmux/1805946

def valid?(version)
  pattern = /^\d+\.\d+\.\d+(-(dev|beta|rc\d+))?$/
  raise "Tried to set invalid version: #{version}" unless version =~ pattern
end

def correct_version(version)
  ver, flag = version.split '-'
  v = ver.split '.'
  (0..2).each do |n|
    v[n] = v[n].to_i
  end
  [v.join('.'), flag].compact.join '-'
end

def read_version
  File.read 'VERSION'
rescue StandardError
  raise "VERSION file not found or unreadable."
end

def write_version(version)
  valid? version
  begin
    File.open 'VERSION', 'w' do |file|
      file.write correct_version(version)
    end
  rescue StandardError
    raise "VERSION file not found or unwritable."
  end
end

def reset(current, which)
  version, flag = current.split '-'
  v = version.split '.'
  which.each do |part|
    v[part] = 0
  end
  [v.join('.'), flag].compact.join '-'
end

def increment(current, which)
  version, flag = current.split '-'
  v = version.split '.'
  v[which] = v[which].to_i + 1
  [v.join('.'), flag].compact.join '-'
end

desc "Prints the current application version"
version = read_version
task version: :environment do
  puts <<~HELP
    Available commands are:
    -----------------------
    ./bin/rails version:patch            # increment the patch x.x.x+1 (keeps any flags on)
    ./bin/rails version:minor            # increment minor and reset patch x.x+1.0 (keeps any flags on)
    ./bin/rails version:major            # increment major and reset others x+1.0.0 (keeps any flags on)
    ./bin/rails version:dev              # set the dev flag on x.x.x-dev
    ./bin/rails version:beta             # set the beta flag on x.x.x-beta
    ./bin/rails version:rc               # set or increment the rc flag x.x.x-rcX
    ./bin/rails version:release          # removes any flags from the current version

  HELP
  puts "Current version is: #{version}"
end

namespace :version do
  desc "Increments the patch version"
  task patch: :environment do
    new_version = increment read_version, 2
    write_version new_version
    puts "Application patched: #{new_version}"
  end

  desc "Increments the minor version and resets the patch"
  task minor: :environment do
    incremented = increment read_version, 1
    new_version = reset incremented, [2]
    write_version new_version
    puts "New version released: #{new_version}"
  end

  desc "Increments the major version and resets both minor and patch"
  task major: :environment do
    incremented = increment read_version, 0
    new_version = reset incremented, [1, 2]
    write_version new_version
    puts "Major application version change: #{new_version}. Congratulations!"
  end

  desc "Sets the development flag on"
  task dev: :environment do
    version, = read_version.split '-'
    new_version = [version, 'dev'].join '-'
    write_version new_version
    puts "Version in development: #{new_version}"
  end

  desc "Sets the beta flag on"
  task beta: :environment do
    version, = read_version.split '-'
    new_version = [version, 'beta'].join '-'
    write_version new_version
    puts "Version in beta: #{new_version}"
  end

  desc "Sets or increments the rc flag"
  task rc: :environment do
    version, flag = read_version.split '-'
    rc = /^rc(\d+)$/.match flag
    new_version = if rc
                    [version, "rc#{rc[1].to_i + 1}"].join '-'
                  else
                    [version, 'rc1'].join '-'
                  end
    write_version new_version
    puts "New version release candidate: #{new_version}"
  end

  desc "Removes any version flags"
  task release: :environment do
    version, = read_version.split '-'
    write_version version
    puts "Released stable version: #{version}"
  end
end
