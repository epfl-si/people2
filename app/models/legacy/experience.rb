class Legacy::Experience < Legacy::BaseCv
  self.table_name = 'parcours'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"
end
