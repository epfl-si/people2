# frozen_string_literal: true

# require 'net/http'
# require Rails.root.join('app/services/application_service').to_s
# require Rails.root.join('app/services/api_base_getter').to_s
# require Rails.root.join('app/services/api_accreds_getter').to_s

class LegacyImportLogFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    ts = time.utc.strftime("%Y%m%d-%H%M%S.%L")
    ms = msg.is_a?(String) ? msg : msg.inspect
    "#{ts} #{severity} -- #{progname} | #{ms}\n"
  end
end

class LegacyProfileImportJob < ApplicationJob
  queue_as :default

  WITH_AI = true
  SKIP_SHIT = false
  SECPOS = [
    { "bio"      => "B" },
    { "research" => "P" },
    { "contact"  => "K" },
    { "research" => "R" },
    { "teaching" => "T" }
  ].freeze
  STDLABELS = {
    "Mission" => "mission",
    "Biographie" => "biography",
    "Biography" => "biography",
    "Current work" => "currwork",
    "Travail en cours" => "currwork",
  }.freeze
  if (lp = Rails.configuration.legacy_import_job_log_path).present?
    JLOG = Logger.new(Rails.root.join("log", lp))
    JLOG.formatter = LegacyImportLogFormatter.new
  else
    JLOG = Rails.logger
  end

  def show_to_visibility(v)
    v == "1" ? AudienceLimitable::VISIBLE : AudienceLimitable::HIDDEN
  end

  def visible_to_visibility(v)
    v ? AudienceLimitable::VISIBLE : AudienceLimitable::HIDDEN
  end

  def hidden_to_visibility(v)
    v ? AudienceLimitable::HIDDEN : AudienceLimitable::VISIBLE
  end

  def award_cats
    @award_cats ||= SelectableProperty.award_category.index_by(&:label)
  end

  def award_orig
    @award_orig ||= SelectableProperty.award_origin.index_by(&:label)
  end

  def education_cats
    @education_cats ||= SelectableProperty.education_category.index_by(&:label)
  end

  def achievement_cats
    @achievement_cats ||= SelectableProperty.achievement_category.index_by(&:label)
  end

  def sections
    @sections ||= Section.all.index_by(&:label)
  end

  def mboxes
    @mboxes ||= ModelBox.all.index_by(&:label)
  end

  def perform(scipers)
    scipers = [scipers] unless scipers.is_a?(Array)
    scipers.each do |sciper|
      do_perform(sciper)
    end
  end

  # Give a second chanche to model by nullifying all its fields
  # with invalid formats. In any case if they are mandatory, there will be
  # the corresponding validation.
  def second_chanche(sciper, m)
    JLOG.warn(sciper) do
      errs = m.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
      "Invalid #{m.class.name}. Trying with second_chanche. #{errs} / #{m.inspect}."
    end
    aa = m.errors.select { |e| %i[invalid url].include?(e.type) }.map { |e| [e.attribute, nil] }.to_h
    m.assign_attributes(aa)
  end

  def do_perform(sciper)
    err_count = 0
    profile = Profile.for_sciper(sciper)
    return if profile.present?

    JLOG.info(sciper) { "Legacy profile import STARTED" }
    begin
      cv = Legacy::Cv.find(sciper)
    rescue StandardError
      JLOG.error(sciper) { "Legacy::Cv base profile for #{sciper} not found" }
      return
    end
    cv_en = cv.translated_part('en')
    cv_fr = cv.translated_part('fr')

    # ------------------------------------------------------------------ Profile
    profile = Profile.new_with_defaults(sciper)
    profile.birthday_visibility = show_to_visibility(cv.datenaiss_show)
    profile.photo_visibility = show_to_visibility(cv.photo_show)

    nat = cv.sanitized_nat
    profile.nationality_en = nat if nat.present?
    profile.nationality_fr = nat if nat.present?
    profile.nationality_visibility = show_to_visibility(cv.nat_show)

    tel = cv.tel_prive&.strip
    if tel.present? && tel
      profile.personal_phone = tel
      profile.personal_phone_visibility = show_to_visibility(cv.tel_prive_show)
    end

    url = cv.web_perso&.strip
    if url.present? && url !~ /(personnes|people)\.epfl\.ch/
      profile.personal_web_url = url
      profile.personal_web_url_visibility = show_to_visibility(cv.web_perso_show)
    end

    # It is important to not fail at this point. Therefore we try to be a bit more indulgents
    unless profile.valid?
      second_chanche(sciper, profile)
      err_count += 1
    end

    unless profile.save
      JLOG.error(sciper) do
        errs = profile.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
        "Could not create new profile for #{sciper} errors: #{errs}."
      end
      return
    end

    # ---------------------------------------------------------------- Accreds
    import_accreds(profile)

    # ------------------------------------------------------------------ Photo
    if cv.photo_ext == "1"
      q = profile.pictures.create(source: "legacy")
      profile.update(selected_picture: q)
    end

    # ---------------------------------------------------------- Special Boxes

    # Expertise is the only rich text  box whose content is in the cv table
    if cv_en&.expertise.present? || cv_fr&.expertise.present?
      e_fr = cv_fr&.sanitized_expertise || ""
      e_en = cv_en&.sanitized_expertise || ""
      if e_en.length < Profile::EXPERTISE_MAX_LEN && e_fr.length < Profile::EXPERTISE_MAX_LEN
        profile.expertise_fr = e_fr if e_fr.present?
        profile.expertise_en = e_en if e_en.present?
      else
        m = mboxes['expertise']
        b = RichTextBox.from_model(m)
        b.profile = profile
        b.content_fr = e_fr if e_fr.present?
        b.content_en = e_en if e_en.present?
        unless b.save
          err_count += 10
          JLOG.warn(sciper) do
            errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            "Skipping invalid expertise field: #{errs}"
          end
        end
      end
    end

    # -------------------------------------------------------- Free Text Boxes
    forcelang = cv.defaultcv
    detect_lang_with_ai = WITH_AI && forcelang.blank?
    JLOG.info(sciper) do
      if forcelang.blank?
        "profile is multilanguage. Language will #{detect_lang_with_ai ? '' : 'NOT'} be auto-detected"
      else
        "profile have #{forcelang} forced language"
      end
    end
    SECPOS.map { |sp| sp.to_a.flatten }.each do |sec, pos|
      box_by_label = {}

      # The default model box is the free box for this section
      mb = mboxes["#{sec}free"]

      sections[sec]
      cv.boxes.visible.free_text.with_content.where(position: pos).order(:label).each do |ob|
        lang = ob.cvlang
        next if forcelang.present? && (lang != forcelang)

        # First check if this is one of the free text boxes with standard label
        smb = STDLABELS[ob.label]
        if smb.present? # standard boxes are published by default
          box_by_label[smb] ||= RichTextBox.from_model(mboxes[smb])
          b = box_by_label[smb]
        else
          # TODO: search if there is already another box of type mb in the
          # other language that might be related to this one.
          # Ollama could help matching the labels.b
          # Asked Natalie if we can just discard this shit but I guess the
          # answer  will be that we have to eat it instead. Therefore, for
          # the moment we get ready for both answers.
          # A third option might be that we import shit anyway but set it as draft
          # so people are somehow forced to do some cleaning.
          next if SKIP_SHIT # non-standard boxes are set as draft

          b = box_by_label[smb] || RichTextBox.from_model(mb)
        end

        b.visibility = 0
        b.profile = profile
        b.send("content_#{lang}=", ob.sanitized_content)
        b.send("title_#{lang}=", ob.sanitized_label)
        next if b.save

        err_count += 100
        JLOG.warn(sciper) do
          errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid box #{ob.id} (sciper: #{profile.sciper}): #{errs}"
        end
      end
    end

    # ---------------------------------------------------------- Special Boxes

    # Expertise is the only rich text  box whose content is in the cv table
    if cv_en&.expertise.present? || cv_fr&.expertise.present?
      m = mboxes['expertise']
      b = RichTextBox.from_model(m)
      b.profile = profile
      b.content_fr = cv_fr.sanitized_expertise if cv_fr&.expertise.present?
      b.content_en = cv_en.sanitized_expertise if cv_en&.expertise.present?
      unless b.save
        err_count += 1000
        JLOG.warn(sciper) do
          errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid expertise: #{errs}"
        end
      end
    end

    # ------------------------------------------------------------ Index Boxes

    # Index boxes are in a single language. For now, we use the
    # profile's forced language or FR.
    # Or may be we could count how many boxes are in the two languages and
    # chose the one where there are most as the preferred...
    # The best would be to have the lang detected by AI but it is quite slow

    if cv.defaultcv.present?
      lang = cv.defaultcv
    else
      nen = cv.boxes.free_text.visible.with_content.where(cvlang: "en").count
      nfr = cv.boxes.free_text.visible.with_content.where(cvlang: "fr").count
      lang = nen >= nfr ? "en" : "fr"
      fallback_lang = lang if detect_lang_with_ai
    end

    # Infoscience links
    is_boxes = cv.boxes.infoscience
    is_boxes.order(:ordre).each do |le|
      e = profile.infosciences.new(
        url: le.src,
        visibility: visible_to_visibility(le.visible?)
      )
      e.title_en = le.sanitized_label if le.label.present?
      next if e.save

      err_count += 10_000
      JLOG.warn(sciper) do
        errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
        "Skipping invalid infoscience box #{le.id}: #{errs}"
      end
    end
    # taken care automagically by IndexBoxable
    # if c.positive?
    #   b = IndexBox.from_model(mboxes['infoscience'])
    #   b.profile = profile
    #   b.save
    # end

    # Publications
    if cv.publications.count.positive?
      b = IndexBox.from_model(mboxes['publication'])
      b.profile = profile
      b.save
      cv.publications.visible.order(:ordre).each do |le|
        e = profile.publications.new(
          title: le.titrepub,
          journal: le.revuepub,
          authors: le.auteurspub,
          visibility: AudienceLimitable::VISIBLE
        )
        e.url = le.urlpub if le.urlpub.present?
        next if e.save

        err_count += 100_000
        JLOG.warn(sciper) do
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid publication #{le.id}: #{errs}"
        end
      end
    end

    # Education
    if cv.educations.count.positive?
      b = IndexBox.from_model(mboxes['education'])
      b.profile = profile
      b.save
      cv.educations.order(:ordre).each do |le|
        lang = le.title_lang? || fallback_lang if detect_lang_with_ai
        e = profile.educations.new(
          year_begin: le.year_begin,
          year_end: le.year_end,
          school: le.univ,
          visibility: AudienceLimitable::VISIBLE
        )
        c = education_cats[le.guess_category] || education_cats["other"]
        e.category = c
        e.send("title_#{lang}=", le.title)
        e.send("field_#{lang}=", le.field) if le.field.present?
        e.director = le.director if le.director.present?
        next if e.save

        err_count += 1_000_000
        JLOG.warn(sciper) do
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid education #{le.id}: #{errs}"
        end
      end
    end

    # Experience
    if cv.experiences.count.positive?
      b = IndexBox.from_model(mboxes['experience'])
      b.profile = profile
      b.save
      cv.experiences.order(:ordre).each do |le|
        lang = le.title_lang? || fallback_lang if detect_lang_with_ai
        e = profile.experiences.new(
          year_begin: le.year_begin,
          year_end: le.year_end,
          visibility: AudienceLimitable::VISIBLE
        )
        e.send("title_#{lang}=", le.title)
        e.location = le.univ if le.univ?
        next if e.save

        err_count += 10_000_000
        JLOG.warn(sciper) do
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid experience #{le.id}: #{errs}"
        end
      end
    end

    # if cv.achievements.count.positive?
    #   b = IndexBox.from_model(mboxes['achievements'])
    #   b.profile = profile
    #   b.save
    #   cv.achievements.order(:ordre).each do |le|
    #     lang = le.description_lang? || fallback_lang if detect_lang_with_ai
    #     e = profile.achievements.new(
    #       year: le.year,
    #       visibility: AudienceLimitable::VISIBLE
    #     )
    #     e.send("description_#{lang}=", le.description)
    #     e.url = le.url if le.url.present?
    #     cat = le.category.present? ? achie_cats[le.category] : achie_cats["other"]
    #     e.category = cat
    #     unless e.save
    #       errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
    #       JLOG.info "Skipping invalid achievement #{le.id} (sciper: #{profile.sciper}): #{errs}"
    #     end
    #   end
    # end

    # Awards
    if cv.awards.count.positive?
      b = IndexBox.from_model(mboxes['award'])
      b.profile = profile
      b.save
      cv.awards.order(:ordre).each do |le|
        lang = le.title_lang? || fallback_lang if detect_lang_with_ai
        e = profile.awards.new(
          year: le.year,
          visibility: AudienceLimitable::VISIBLE
        )
        e.send("title_#{lang}=", le.title)
        e.issuer = le.grantedby if le.grantedby.present?
        e.url = le.url if le.url.present?
        e.category = award_cats[le.category] if le.category.present?
        e.origin = award_orig[le.origin] if le.origin.present?
        next if e.save

        err_count += 100_000_000
        JLOG.warn(sciper) do
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid award #{le.id}: #{errs}"
        end
      end
    end

    # Research IDs
    if cv.social_ids.with_content.count.positive?
      b = IndexBox.from_model(mboxes['social'])
      b.profile = profile
      b.save
      cv.social_ids.with_content.each do |le|
        unless Social.tag?(le.tag)
          JLOG.warn(sciper) do
            "Skipping ResearchId with tag #{le.tag} due to inexistent corresponding Social"
          end
          next
        end

        e = profile.socials.new(
          tag: le.tag,
          value: le.content,
          visibility: le.visible? ? AudienceLimitable::VISIBLE : AudienceLimitable::HIDDEN
        )
        next if e.save

        err_count += 1_000_000_000
        JLOG.warn(sciper) do
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          "Skipping invalid research id #{le.id}/#{le.tag}: #{errs}"
        end
      end
    end

    JLOG.info(sciper) { "Legacy profile import DONE. Errors: #{err_count}" }
  end

  # import the legacy accred preferences (only for still valid accreds)
  def import_accreds(profile)
    accreds = Accreditation.for_sciper(profile.sciper)
    return unless accreds.count > 1

    prefs = Legacy::AccredPref.where(sciper: profile.sciper).order('ordre')
    return if prefs.empty?

    abu = accreds.index_by(&:unit_id)
    prefs.each_with_index do |pref, _order|
      next unless (a = abu[pref.unit.to_i])

      profile.accreds.create({
                               sciper: a.sciper,
                               unit_id: a.unit_id,
                               unit_en: a.unit_label_en,
                               unit_fr: a.unit_label_fr,
                               unit_it: a.unit_label_en,
                               unit_de: a.unit_label_en,
                               role: a.position,
                               visibility: visible_to_visibility(pref.visible?),
                               address_visibility: visible_to_visibility(pref.visible_addr?),
                             })
    end
  end
end
