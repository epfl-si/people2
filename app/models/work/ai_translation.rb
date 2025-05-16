# frozen_string_literal: true

# This contains various text taht require AI translation and/or language detection
module Work
  class AiTranslation < Work::Base
    belongs_to :text
  end
end
