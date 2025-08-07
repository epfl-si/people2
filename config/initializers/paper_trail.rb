# frozen_string_literal: true

PaperTrail.config.enabled = true
PaperTrail.serializer = PaperTrail::Serializers::JSON
# PaperTrail.config.has_paper_trail_defaults = {
#   on: %i[create update destroy]
# }
# PaperTrail.config.version_limit = 3
