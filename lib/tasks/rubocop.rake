# frozen_string_literal: true

require "rubocop"

namespace :rubocop do
  desc "Dump the full RuboCop config as a YAML file"
  task dump: :environment do
    file = ".rubocop.yml"

    file_config = RuboCop::ConfigLoader.load_file(file)
    config = RuboCop::ConfigLoader.merge_with_default(file_config, file)
    output = config.to_h.to_yaml.gsub(config.base_dir_for_path_parameters, "")

    output.gsub!(/\s\n/, "\n")
    puts output
  end
end
