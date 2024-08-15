# frozen_string_literal: true

# Concern for adding named properties that are selectable (enum like) from
# the SelectableProperty model. Also adds
# 1. class methods for listing all the available properties
# 2. validation that the connected property is of the correct kind
module WithSelectableProperties
  extend ActiveSupport::Concern
  included do
    def self.with_selectable_properties(*attributes)
      attributes.each do |prop|
        sprop = prop.to_s
        cname = to_s.downcase

        self.class.send(:define_method, sprop.pluralize) do
          SelectableProperty.where(property: "#{cname}_#{sprop}")
        end
        self.class.send(:define_method, "#{sprop}_ids") do
          SelectableProperty.where(property: "#{cname}_#{sprop}").map(&:id)
        end

        belongs_to prop, class_name: "SelectableProperty"
        validates "#{prop}_id".to_sym,
                  inclusion: { in: send("#{prop}_ids"), message: "is not a property of correct type" }

        define_method("t_#{prop}") do |_locale = I18n.locale|
          send(sprop).t_name
        end
      end
    end
  end
end
