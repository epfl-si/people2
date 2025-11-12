# frozen_string_literal: true

# Delete all accred prefs of profiles that have not changed them to
# force importing a new default next time the profile is visited.
class AccredsResetJob < ApplicationJob
  def perform
    # Accred.where('timestampdiff(SECOND, updated_at, created_at) <= 10').pluck(:profile_id).uniq.count
    # profile_ids that have more than one accred
    malist = Accred.group(:profile_id).count.select { |_k, v| v > 1 }.keys
    # profile_ids that have at least one accred manually modified
    uplist = Accred.where('timestampdiff(SECOND, created_at, updated_at) > 10').pluck(:profile_id).uniq

    deletable = malist - uplist
    Accred.where(profile_id: deletable).delete_all
  end
end
