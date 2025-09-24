# frozen_string_literal: true

module Oasis
  class Phd
    attr_reader :sciper, :director_sciper, :codirector_sciper, :cursus, :date, :thesis_number, :thesis_title

    def initialize(data)
      @sciper = data['sciper']
      @director_sciper = data['directeurThese']
      @codirector_sciper = data['codirecteurThese']
      @cursus = data['cursus']
      @date = parse_date(data['dateRemiseDiplome'])
      @thesis_number = data['numeroThese']
      @thesis_title = data['titreThese']
    end

    def id
      @sciper
    end

    def parse_date(d)
      d.present? ? Date.parse(d) : nil
    end

    def updated_phd(phd: nil, year: Time.zone.today.year)
      phd ||= ::Phd.new(sciper: @sciper)
      phd.assign_attributes({
                              sciper: @sciper,
                              director_sciper: @director_sciper,
                              codirector_sciper: @codirector_sciper,
                              cursus: @cursus,
                              date: @date,
                              thesis_number: @thesis_number,
                              thesis_title: @thesis_title,
                            })
      phd.year = year if phd.year.blank? || phd.year < year
      phd
    end

    def ==(other)
      @sciper = other.sciper
    end
  end
end
