# frozen_string_literal: true

# Idea taken from:
# https://phrase.com/blog/posts/localizing-rails-active-record-models/
# Ensure that the creation of an IndexBox as soon as the first record is saved
module IndexBoxable
  extend ActiveSupport::Concern

  included do
    before_create :ensure_index_box_exists
  end
  def ensure_index_box_exists
    return if profile.index_boxes.where(subkind: self.class.name).present?

    mb = ModelBox.where(kind: 'IndexBox', subkind: self.class.name).first
    b = mb.new_box_for_profile(profile)
    b.save!
  end
end
