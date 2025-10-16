# frozen_string_literal: true

module Legacy
  class Award < Legacy::BaseCv
    self.table_name = 'awards'

    include Ollamable
    ollamizes :title

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :awards

    def self.all_categories
      @all_categories ||= SelectableProperty.award_category.index_by(&:label)
    end

    def self.all_origins
      @all_origins ||= SelectableProperty.award_origin.index_by(&:label)
    end

    CAT_LABELS =  {
      "Fellowship or nomination" => "fellowship",
      "Research grant" => "other",
      "Honorary doctorate" => "honorary",
      "Major award, medal or prize" => "majour",
      "Discipline specific award" => "discipline",
      "Teaching award" => "teaching",
      "Best publication, poster or thesis" => "best",
      "Other" => "other",
    }.freeze
    def category_as_property
      label = CAT_LABELS[category] || "other"
      Award.all_categories[label]
    end

    ORI_LABELS = {
      "Switzerland" => "suisse",
      "International" => "international",
      "Internal" => "epfl",
      "EPFL" => "epfl"
    }.freeze

    def origin_as_property
      label = ORI_LABELS[origin]
      Award.all_origins[label]
    end

    # we can pass either lang or fallback_lang. Presence of fallback_lang means
    # that we want to use ai to guess the language
    def to_award(lang, profile: nil, fallback_lang: nil)
      # debugger

      final_lang = if fallback_lang.present?
                     title_lang? || fallback_lang
                   else
                     lang || 'en'
                   end
      e = ::Award.new(
        year: year,
        visibility: AudienceLimitable::VISIBLE
      )
      e.profile = profile if profile.present?
      e.send("title_#{final_lang.downcase}=", title)
      e.issuer = grantedby if grantedby.present?
      e.url = url if url.present?
      e.category = category_as_property if category.present?
      e.origin = origin_as_property if origin.present?
      e
    end
  end
end
