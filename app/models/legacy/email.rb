class Legacy::Email < Legacy::BaseDinfo
  self.table_name = 'emails'
  self.primary_key = 'sciper'
  belongs_to :person, class_name: "Person", foreign_key: "sciper"
  def address
    addrlog
  end
end
