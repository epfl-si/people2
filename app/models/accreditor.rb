# frozen_string_literal: true

class Accreditor < OpenStruct
  # TODO: implement this with data coming from api !!!
  def self.for_sciper(sciper)
    data = APIAuthGetter.call(onpersid: sciper, type: 'right', authid: 'accreditation', alldata: 1)
    return if data.blank?

    data.map { |d| new(d['person']) }
  end

  def display
    "#{firstnameusual.presence || firstname} #{lastnameusual.presence || lastname}"
  end
end
