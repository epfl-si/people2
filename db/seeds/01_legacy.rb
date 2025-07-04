# frozen_string_literal: true

Rake.application['legacy:scipers'].invoke if Work::Sciper.count.zero?
Rake.application['legacy:adoptions'].invoke if Work::Sciper.count.zero?
Rake.application['legacy:fetch_all_texts'].invoke if Work::Text.count.zero?
Rake.application['legacy:txt_lang_detect'].invoke if Work::AiTranslation.count.zero?
