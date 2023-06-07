require 'yaml'

def seed_cv
  # yaml aliases are no longer enabled in latest yaml parser default "safe" mode
  data = YAML.unsafe_load_file("#{DEV_SEEDS_DIR}/cv.yml")["cvs"]
  return unless data
  tcontent = [
      "curriculum",
      "expertise", 
      "mission"
    ].map{|k| LANGS.map{|l| "#{k}_#{l}"}}.flatten

  data.each do |k, d|
    sciper=d["sciper"]
    bd=d.slice(
      "show_birthday",
      "show_curriculum",
      "show_expertise",
      "show_function",
      "show_education",
      "show_mission",
      "show_nationality",
      "show_phone",
      "show_photo",
      "personal_web_url",
      "nationality_en",
      "nationality_fr",
    )

    puts "Creating cv with sciper = #{sciper} and the following base data"
    puts bd.inspect
    cv=Cv.new(bd)
    cv.sciper = sciper
    cv.save
    tcontent.each do |k|
      if d[k].present?
        ActionText::RichText.create!(
          record_type: 'Cv', 
          record_id: cv.id, 
          name: k,
          body: d[k],
        )
      end
    end
  end
end

seed_cv if Cv.count == 0
