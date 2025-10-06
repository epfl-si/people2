# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class PicturesCleanupJob < ApplicationJob
  queue_as :default

  def perform
    # Especially in the early time when we had issues with the Work DB,
    # we had pictures for which the fetch job were actually not submitted
    # and the picture remained just an empty container.
    # The signatuer symptom is that they do not have an attached without_image
    # but never failed (because the job were actually never submitted)
    Picture.without_image.where(failed_attempts: 0).find_each(&:fetch!)

    PaperTrail.request(enabled: false) do
      # It is useless to keep images that failed to fetch too many times
      dpic = Picture.where('failed_attempts >= ?', Picture::MAX_ATTEMPTS).destroy_all
      if dpic.present?
        picture_ids = dpic.map(&:id)
        Profile.where(camipro_picture_id: picture_ids).update_all(camipro_picture_id: nil)
        Profile.where(selected_picture_id: picture_ids).update_all(selected_picture_id: nil)
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
