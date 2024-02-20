# frozen_string_literal: true

# Check that at least one attribute of a translatable set is present
class TranslatabilityValidator < ActiveModel::EachValidator
  def validate_each(record, t_attribute, _value)
    attribute = t_attribute[2..]
    pp = %w[en fr].map { |l| record.attributes["#{attribute}_#{l}"].present? }
    return if pp.any?

    %w[en fr].each do |l|
      record.errors.add("#{attribute}_#{l}", "at least one of the translations must be present")
    end
  end
end
