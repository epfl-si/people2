require 'yaml'

def seed_cv
  # yaml aliases are no longer enabled in latest yaml parser default "safe" mode
  data = YAML.unsafe_load_file("#{DEV_SEEDS_DIR}/cv.yml")["cvs"]
  return unless data

  data.each do |k, d|
    sciper=d["sciper"]
    bd=d.slice(
      "show_birthday",
      "show_function",
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
    cv.init_boxes!

    cv.boxes.each do |b|
      k="#{b.kind}_#{b.locale}"
      if d[k].present?
        b.content = d[k]
      end   
      k="show_#{b.kind}"
      if d[k].present?
        b.visible = d[k]
      else
        b.visible = false
      end 
      b.save
    end

    if d['photo'].present?
      p=DEV_SEEDS_DIR + "/" + d['photo']
      if File.exists?(p)
        cv.profile_pictures.create(image: File.open(p))
      end
    end

    # tcontent.each do |k|
    #   if d[k].present?
    #     ActionText::RichText.create!(
    #       record_type: 'Cv', 
    #       record_id: cv.id, 
    #       name: k,
    #       body: d[k],
    #     )
    #   end
    # end
  end
end

      # "show_curriculum",
      # "show_expertise",
      # "show_education",
      # "show_mission",


seed_cv if Cv.count == 0
