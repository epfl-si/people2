# frozen_string_literal: true

class CamiproPictureCacheJob < ApplicationJob
  queue_as :default

  def perform(id)
    picture = CamiproPicture.where(id: id).includes(:profile).first
    return unless picture

    begin
      picture.fetch!
    rescue StandardError
      picture.failed_attempts += 1
      picture.save
    end
  end
end
