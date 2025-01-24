# frozen_string_literal: true

json.array! @achievements, partial: "achievements/achievement", as: :achievement
