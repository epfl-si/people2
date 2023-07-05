require 'yaml'

def seed_sections
  data = YAML.unsafe_load_file("#{SEEDS_DIR}/sections.yml")["sections"]
  return unless data

  data.each do |d|
    next if 
    s=Section.where(label: d['label']).first || Section.create(d.slice("title_en", "title_fr", "label", "zone", "show_title", "create_allowed"))
    if d['model_boxes'].present?
      d['model_boxes'].each do |b|
        next if ModelBox.where(label: b["label"]).present?
        s.model_boxes.create({
          locale: l,
          label: b["label"],
          title_en: b["title_en"],
          title_fr: b["title_fr"],
          show_title: b["show_title"],
        })
      end
    end
  end
end

# seed_sections if Section.count == 0
