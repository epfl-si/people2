# frozen_string_literal: true

module Work
  class SpywareLog < Work::Base
    OPDO_EVENT = {
      'create': 'c',
      'read': 'r',
      'update': 'u',
      'destroy': 'd',
    }.freeze

    self.table_name = 'versions'

    scope :uploadanda, -> { where(uploaded_at: nil) }
    scope :uploaded, -> { where.not(uploaded_at: nil) }

    # Pour rappel, la structure de données est la suivante:
    # doc = {
    #   @timestamp = timestamp au format ISO-8601 (ex: “2024-10-10T11:34:03+02:00”)
    #   handler_id = personne ou système ayant effectué le traitement
    #   handled_id = personne dont l’information a été traitée (peut contenir des entrées multiples)
    #   crudt = Action CRUD+T
    #   source = système source (nom, adresse IP, etc)
    #   payload = Champ texte avec le détail du traitement
    # }
    def to_opdo
      {
        "@timestamp": created_at,
        handler_id: author_sciper || "batch",
        handled_id: subject_sciper || "NA",
        crudt: OPDO_EVENT[event],
        source: ip || "NA",
        payload: object_changes || object
      }
    end
  end
end
