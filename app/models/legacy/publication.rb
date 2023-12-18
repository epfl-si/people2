class Legacy::Publication < Legacy::BaseCv
  self.table_name = 'publications'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"

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
