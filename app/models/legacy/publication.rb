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
  end
end
