class Legacy::AccredPref < Legacy::BaseCv
  self.table_name = 'accreds'
  self.primary_key = nil

  def self.by_sciper(sciper)
    where(sciper:).order(:ordre)
  end

  def order
    ordre
  end

  def unit_id
    unit
  end

  def hidden?
    accred_show == 0
  end
end
