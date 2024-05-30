# frozen_string_literal: true

json.array! @awards, partial: "awards/award", as: :award
