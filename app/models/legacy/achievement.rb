class Legacy::Achievement < Legacy::BaseCv
  self.table_name = 'achievements'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"
end
