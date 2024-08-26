# frozen_string_literal: true

module EducationHelper
  def period_text(year_begin, year_end)
    year_end = year_end.presence || t('education.period_status')
    "#{year_begin} – #{year_end}"
  end
end
