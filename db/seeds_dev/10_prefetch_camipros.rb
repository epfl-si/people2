# frozen_string_literal: true

Picture.camipro.reject { |p| p.image.attached? }.each(&:fetch!)
