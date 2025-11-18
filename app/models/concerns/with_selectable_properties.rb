# frozen_string_literal: true

# Concern for adding named properties that are selectable (enum like) from
# the SelectableProperty model. Also adds
# 1. class methods for listing all the available properties
# 2. validation that the connected property is of the correct kind
module WithSelectableProperties
  extend ActiveSupport::Concern
  included do
    def self.with_selectable_properties(*attributes)
      cname = name.underscore
      attributes.each do |prop|
        define_singleton_method(prop.to_s.pluralize) do
          SelectableProperty.where(property: "#{cname}_#{prop}")
        end
        define_singleton_method("default_#{prop}") do
          SelectableProperty.where(property: "#{cname}_#{prop}", default: true).first
        end
        define_singleton_method("#{prop}_ids") do
          SelectableProperty.where(property: "#{cname}_#{prop}").map(&:id)
        end

        belongs_to prop, class_name: "SelectableProperty"
        validates "#{prop}_id".to_sym,
                  inclusion: { in: send("#{prop}_ids"), message: :incorrect_type }

        define_method("t_#{prop}") do |_locale = I18n.locale|
          send(prop).t_name
        end
      end
    end
  end
end
