# frozen_string_literal: true

Profile.where(camipro_picture_id: nil).find_each(&:cache_camipro_picture!)
