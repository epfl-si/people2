class Legacy::ResearchDomain < Legacy::BaseCv
  self.table_name = 'profresearch'
  belongs_to :cv, class_name: "Cv", foreign_key: "sciper"
end
