# frozen_string_literal: true

# Check that at least one attribute of a translatable set is present
class TranslatabilityValidator < ActiveModel::EachValidator
  def validate_each(record, t_attribute, _value)
    attribute = t_attribute[2..]
    pp = I18n.available_locales.map do |l|
      record.attributes["#{attribute}_#{l}"].present?
    end
    return if pp.any?

    I18n.available_locales.map.each do |l|
      record.errors.add("#{attribute}_#{l}", I18n.t("errors.messages.untranslatable"))
    end
  end
end
