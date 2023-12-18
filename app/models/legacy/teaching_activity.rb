class Legacy::TeachingActivity < Legacy::BaseCv
  self.table_name = 'teachingact'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"
end
