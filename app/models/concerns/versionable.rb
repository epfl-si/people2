# frozen_string_literal: true

module Versionable
  extend ActiveSupport::Concern
  included do
    has_paper_trail(
      # if:     Proc.new { |t| ... },
      # unless: Proc.new { |t| ... },
      ignore: %i[created_at updated_at],
      # only: [:sensible_field, ...],
      versions: { class_name: 'Work::Version' },
      meta: {
        subject_sciper: proc do |m|
          if m.respond_to?(:sciper)
            m.sciper
          elsif m.respond_to?(:profile)
            m.profile.sciper
          end
        end
      }
    )
  end
end
