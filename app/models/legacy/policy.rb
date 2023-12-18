class Legacy::Policy < Legacy::BaseAccred
  self.table_name = 'accreds_properties'
  self.primary_key = nil

  belongs_to :person, class_name: "Person", foreign_key: "persid"
  belongs_to :property, class_name: "Property", foreign_key: "propid"

  default_scope do
    where(finval: nil).includes(:property)
  end
end
