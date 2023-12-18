class Legacy::Education < Legacy::BaseCv
  self.table_name = 'edu'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"
end
