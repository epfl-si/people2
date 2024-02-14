# frozen_string_literal: true

class Position
  attr_reader :id, :label_en, :label_frm, :label_fri, :label_frf

  include Translatable
  inclusively_translates :label

  def initialize(h)
    @id = h.key?('id') ? h['id'] : 0
    @label_en = h['labelen']
    @label_frm = h['labelfr']
    @label_fri = h.key?('labelinclusive') ? h['labelinclusive'] : h['labelfr']
    @label_frf = h.key?('labelxx') ? h['labelxx'] : h['labelfr']
  end

  # In the original People, prof were determined by the followint regex
  # /ordinaire|tenure|assoc|bours|enseignement|titulaire|professeur invit/
  # TODO: there must be a better way using accred properties or similar
  PROF_RE = /(^Profess)|enseignement/i
  def possibly_teacher?
    PROF_RE.match(@label_frm)
  end

  ENS_RE = /professeur honoraire|-ENS$/i
  def enseignant?
    ENS_RE.match(@label_frm)
  end
end
