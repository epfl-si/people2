# frozen_string_literal: true

class Accreditor < OpenStruct
  def self.for_sciper(sciper)
    data = APIAuthGetter.call(onpersid: sciper, type: 'right', authid: 'accreditation', alldata: 1)
    return if data.blank?

    # We need some few more information regarding the origin of the accreditorship
    # in the function change form where we want to keep only direct accreditors
    extra = %w[attribution authid reasontype reasonresourceid reasonname]
    data.map { |d| new(d['person'].merge(d.slice(*extra))) }
  end

  def display
    "#{firstnameusual.presence || firstname} #{lastnameusual.presence || lastname}"
  end
end
