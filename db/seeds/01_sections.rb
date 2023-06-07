require 'yaml'

def seed_sections
  data = YAML.unsafe_load_file("#{SEEDS_DIR}/sections.yml")["sections"]
  return unless data

  data.each do |d|
    s=Section.create(d.slice("title_en", "title_fr", "show_title", "create_allowed"))
    if d['model_boxes'].present?
      d['model_boxes'].each do |b|
        LANGS.each do |l|
          s.model_boxes.create({
            locale: l,
            label: b["label"],
            title: b["title_#{l}"],
            show_title: b["show_title"],
          })
        end
      end
    end
  end
end

seed_sections if Section.count == 0
