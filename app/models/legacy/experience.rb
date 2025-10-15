# frozen_string_literal: true

module Legacy
  class Experience < Legacy::BaseCv
    self.table_name = 'parcours'

    include Ollamable
    ollamizes :title

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :experiences

    # DATES_RE = /([0-9]{4}).*?([0-9]{4})?/
    DATES_RE = /([0-9]{4})(.*?([0-9]{4}))?/

    def year_begin
      years[0]
    end

    def year_end
      years[1]
    end

    def years
      @years ||= begin
        m = DATES_RE.match(dates)
        if m.present?
          yb = m[1]
          ye = m[3] || yb
        else
          yb = nil
          ye = nil
        end
        [yb, ye]
      end
    end

    def to_experience(lang, profile: nil, fallback_lang: nil)
      # debugger

      final_lang = if fallback_lang.present?
                     title_lang? || fallback_lang
                   else
                     lang || 'en'
                   end

      e = ::Experience.new(
        year_begin: year_begin,
        year_end: year_end,
        visibility: AudienceLimitable::VISIBLE
      )
      e.send("title_#{final_lang.downcase}=", title)
      e.location = univ if univ?
      e.profile = profile if profile.present?
      e
    end
  end
end
