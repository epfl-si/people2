# frozen_string_literal: true

module Legacy
  class Education < Legacy::BaseCv
    self.table_name = 'edu'

    include Ollamable
    ollamizes :title

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :educations

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

    RE_PDO = Regexp.new("Post.*[Dd]oc")
    RE_PHD = Regexp.new(
      "Ph\.?[dD]\.?|Doctor of (Ph|Sc)|DPhil|(Docteur|Dr\.?) .* [sS]c(\.|iences)|Doctorat|Dr\."
    )
    RE_MAS = Regexp.new("MSc?|Ms\.Sc\.|Master|Graduate|MPhil|MAS?|DEA|M\.S\.")
    RE_BAC = Regexp.new("Bachel|B\.?Sc|B\.?Arch|B\.?Eng|BA|B\.?S\.?|S\.B\.|Architecte EPFL|Dipl.*Ing")
    RE_MAT = Regexp.new("Maturit|Baccala|High School")
    RE_CFC = Regexp.new("CFC|Brevet f.*d.*ral")
    def guess_category
      case "#{title} #{field}"
      when RE_PDO
        "postdoc"
      when RE_PHD
        "phd"
      when RE_MAS
        "master"
      when RE_BAC
        "bachelor"
      when RE_MAT
        "matu"
      when RE_CFC
        "cfc"
      else
        "other"
      end
    end
  end
end
