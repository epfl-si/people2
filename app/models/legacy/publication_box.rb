# frozen_string_literal: true

# The boxes with publication data contain a lot of shit. I think we should reset
# and ask users to rewrite them or just kill this feature.
module Legacy
  class PublicationBox < Legacy::Box
    default_scope do
      where(position: 'P').where.not(sys: 'I')
    end
  end
end
