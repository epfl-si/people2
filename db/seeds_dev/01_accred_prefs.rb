# frozen_string_literal: true

Profile.all.find_each do |profile|
  Legacy::AccredPref.for_sciper(profile.sciper).each do |ap|
    profile.accred_prefs.create(
      sciper: profile.sciper,
      unit_id: ap.unit,
      order: ap.ordre,
      hidden: ap.hidden?,
      hidden_addr: ap.hidden_addr?
    )
  end
end
