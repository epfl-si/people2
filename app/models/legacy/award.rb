class Legacy::Award < Legacy::BaseCv
  self.table_name = 'awards'
  belongs_to :person, class_name: "Person", foreign_key: "sciper"
end
