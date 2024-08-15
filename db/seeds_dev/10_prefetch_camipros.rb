# frozen_string_literal: true

Picture.where(camipro: true).reject { |p| p.image.attached? }.each(&:fetch!)
