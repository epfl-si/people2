# frozen_string_literal: true

# {
#   "id"=>13030,
#   "name"=>"ISAS-FSD",
#   "labelfr"=>"Développement Full-Stack",
#   "labelen"=>"Full-Stack Development ",
#   "path"=>"EPFL VPO-SI ISAS ISAS-FSD",
#   "level"=>4,
#   "cf"=>"1906"
# },
class BulkUnit < OpenStruct
  include Translatable
  translates :label

  def initialize(data)
    r = data.slice('id', 'name', 'path').merge({
                                                 label_en: data['labelen'],
                                                 label_fr: data['labelfr'],
                                                 label_it: data['labelen'],
                                                 label_de: data['labelen'],
                                               })
    super(r)
  end

  def hierarchy
    path
  end
end
