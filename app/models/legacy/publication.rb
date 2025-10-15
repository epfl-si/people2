# frozen_string_literal: true

module Legacy
  class Publication < Legacy::BaseCv
    self.table_name = 'publications'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :publications

    scope :visible, -> { where(showpub: '1').order(:ordre) }

    def author
      auteurspub
    end

    def title
      titrepub
    end

    def journal
      revuepub
    end

    def url
      urlpub
    end

    def to_publication(profile: nil)
      e = ::Publication.new(
        title: titrepub,
        journal: revuepub,
        authors: auteurspub,
        visibility: AudienceLimitable::VISIBLE
      )
      e.profile = profile if profile.present?
      e.url = urlpub if urlpub.present?
      e
    end
  end
end
