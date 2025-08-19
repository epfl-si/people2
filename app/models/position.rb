# frozen_string_literal: true

class Position
  attr_reader :id, :label_en, :label_frm, :label_fri, :label_frf, :label_it, :label_de

  include Translatable
  inclusively_translates :label

  def initialize(h)
    @id = h.key?('id') ? h['id'] : 0

    @label_frm = h['labelfr']
    @label_fri = h.key?('labelinclusive') ? h['labelinclusive'] : h['labelfr']
    @label_frf = h.key?('labelxx') ? h['labelxx'] : h['labelfr']
    @label_en = h['labelen']

    # api.epfl.ch does not provide status labels in IT and DE locale
    @label_it = @label_en
    @label_de = @label_en
  end

  def self.load(payload)
    return nil if payload.nil?

    data = YAML.safe_load(payload)
    new(data)
  end

  def self.dump(position)
    YAML.safe_dump(
      "id" => position.id,
      "labelen" => position.label_en,
      "labelfr" => position.label_frm,
      "labelinclusive" => position.label_fri,
      "labelxx" => position.label_frf
    )
  end

  def match_legacy_filter?(filter)
    filter.match?(label_frm)
  end

  # In the original People, prof were determined by the followint regex
  # /ordinaire|tenure|assoc|bours|enseignement|titulaire|professeur invit/
  # TODO: there must be a better way using accred properties or similar
  PROF_RE = /^Profess|enseignement|cours$/i
  def possibly_teacher?
    PROF_RE.match(@label_frm)
  end

  ENS_RE = /professeur honoraire|-ENS$/i
  def enseignant?
    ENS_RE.match(@label_frm)
  end

  def professor_emeritus?
    @label_frm == "Professeur honoraire"
  end
end
