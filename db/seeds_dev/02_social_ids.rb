# frozen_string_literal: true

Profile.all.find_each do |profile|
  Legacy::SocialId.for_sciper(profile.sciper).each do |ap|
    next if ap.content.blank?

    profile.socials.create(
      sciper: profile.sciper,
      tag: ap.tag,
      value: ap.content,
      order: (ap.ordre.nil? ? 1 : ap.ordre.to_i),
      hidden: ap.id_show == '1'
    )
  end
end
