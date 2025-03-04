# frozen_string_literal: true

# require 'net/http'
# require Rails.root.join('app/services/application_service').to_s
# require Rails.root.join('app/services/api_base_getter').to_s
# require Rails.root.join('app/services/api_accreds_getter').to_s

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

  def perform(scipers)
    achie_cats = SelectableProperty.achievement_category.index_by(&:label)
    award_cats = SelectableProperty.award_category.index_by(&:label)
    award_orig = SelectableProperty.award_origin.index_by(&:label)

    sections = Section.all.index_by(&:label)
    mboxes = ModelBox.all.index_by(&:label)

    scipers = [scipers] unless scipers.is_a?(Array)

    (scipers.is_a?(Array) ? scipers : [scipers]).each do |sciper|
      profile = Profile.for_sciper(sciper)
      next if profile.present?

      begin
        cv = Legacy::Cv.find(sciper)
      rescue StandardError
        next
      end
      cv_en = cv.translated_part('en')
      cv_fr = cv.translated_part('fr')

      # ---------------------------------------------------------------- Profile
      profile = Profile.new_with_defaults(sciper)
      profile.show_birthday = cv.datenaiss_show == "1"
      profile.show_photo = cv.photo_show == "1"

      nat = cv.sanitized_nat
      profile.nationality_en = nat if nat.present?
      profile.nationality_fr = nat if nat.present?
      profile.show_nationality = cv.nat_show == "1"

      tel = cv.tel_prive&.strip
      profile.phone = tel if tel.present?
      profile.show_phone = cv.tel_prive_show == "1"

      url = cv.web_perso&.strip
      profile.personal_web_url = url if url.present?
      profile.show_weburl = cv.web_perso_show == "1"

      unless profile.save
        errs = profile.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
        Rails.logger.debug "ERROR creating profile: #{errs}"
        next
      end

      # ---------------------------------------------------------------- Accreds
      import_accreds(profile)

      # ---------------------------------------------------------- Special Boxes

      # Expertise is the only rich text  box whose content is in the cv table
      if cv_en.expertise.present? || cv_fr.expertise.present?
        e_fr = cv_fr.sanitized_expertise || ""
        e_en = cv_en.sanitized_expertise || ""
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
            errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid expertise (sciper: #{profile.sciper}): #{errs}"
          end
        end
      end

      # -------------------------------------------------------- Free Text Boxes
      forcelang = cv.defaultcv
      detect_lang_with_ai = WITH_AI && forcelang.blank?
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

          b.audience = 0
          b.visibility = 0
          b.profile = profile
          b.send("content_#{lang}=", ob.sanitized_content)
          b.send("title_#{lang}=", ob.sanitized_label)
          unless b.save
            errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid box #{ob.id} (sciper: #{profile.sciper}): #{errs}"
          end
        end
      end

      # ---------------------------------------------------------- Special Boxes

      # Expertise is the only rich text  box whose content is in the cv table
      if cv_en.expertise.present? || cv_fr.expertise.present?
        m = mboxes['expertise']
        b = RichTextBox.from_model(m)
        b.profile = profile
        b.content_fr = cv_fr.sanitized_expertise if cv_fr.expertise.present?
        b.content_en = cv_en.sanitized_expertise if cv_en.expertise.present?
        unless b.save
          errs = b.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          Rails.logger.debug "Skipping invalid expertise (sciper: #{profile.sciper}): #{errs}"
        end
      end

      # ------------------------------------------------------------ Index Boxes

      # Index boxes are in a single language. For now, we use the
      # profile's forced language or FR.
      # Or may be we could count how many boxes are in the two languages and
      # chose the oen where there are more as the preferred...
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
          visibility: le.visible? ? 0 : 2
        )
        e.title_en = le.sanitized_label if le.label.present?
        unless e.save
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          Rails.logger.debug "Skipping invalid infoscience box #{le.id} (sciper: #{profile.sciper}): #{errs}"
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
            audience: 0,
            visibility: 0
          )
          e.url = le.urlpub if le.urlpub.present?
          unless e.save
            errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid publication #{le.id} (sciper: #{profile.sciper}): #{errs}"
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
            audience: 0,
            visibility: 0
          )
          e.send("title_#{lang}=", le.title)
          e.send("field_#{lang}=", le.field) if le.field.present?
          e.director = le.director if le.director.present?
          unless e.save
            errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid education #{le.id} (sciper: #{profile.sciper}): #{errs}"
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
            audience: 0,
            visibility: 0
          )
          e.send("title_#{lang}=", le.title)
          e.send("field_#{lang}=", le.field) if le.field.present?
          e.location = le.univ if le.director.univ?
          unless e.save
            errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid experience #{le.id} (sciper: #{profile.sciper}): #{errs}"
          end
        end
      end

      if cv.achievements.count.positive?
        b = IndexBox.from_model(mboxes['achievements'])
        b.profile = profile
        b.save
        cv.achievements.order(:ordre).each do |le|
          lang = le.description_lang? || fallback_lang if detect_lang_with_ai
          e = profile.achievements.new(
            year: le.year,
            audience: 1,
            visibility: 0
          )
          e.send("description_#{lang}=", le.description)
          e.url = le.url if le.url.present?
          cat = le.category.present? ? achie_cats[le.category] : achie_cats["other"]
          e.category = cat
          unless e.save
            errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
            Rails.logger.debug "Skipping invalid achievement #{le.id} (sciper: #{profile.sciper}): #{errs}"
          end
        end
      end

      next unless cv.awards.count.positive?

      b = IndexBox.from_model(mboxes['award'])
      b.profile = profile
      b.save
      cv.awards.order(:ordre).each do |le|
        lang = le.title_lang? || fallback_lang if detect_lang_with_ai
        e = profile.awards.new(
          year: le.year,
          audience: 0,
          visibility: 0
        )
        e.send("title_#{lang}=", le.title)
        e.issuer = le.grantedby if le.grantedby.present?
        e.url = le.url if le.url.present?
        e.category = award_cats[le.category] if le.category.present?
        e.origin = award_orig[le.origin] if le.origin.present?
        unless e.save
          errs = e.errors.map { |err| "#{err.attribute}: #{err.type}" }.join(", ")
          Rails.logger.debug "Skipping invalid award #{le.id} (sciper: #{profile.sciper}): #{errs}"
        end
      end
    end
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
                               visible: pref.visible?,
                               visible_addr: pref.visible_addr?,
                             })
    end
  end
end
