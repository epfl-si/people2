# frozen_string_literal: true

require 'yaml'

def seed_selectable_properties
  data = YAML.unsafe_load_file("#{SEEDS_DIR}/selectable_properties.yml")
  return unless data

  data.each do |d|
    SelectableProperty.find_or_create_by(d)
  end
end
