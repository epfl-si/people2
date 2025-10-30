# frozen_string_literal: true

# Compile the list of classes that include AudienceLimitable and
# eventually other future modules

module SafeReflection
  module_function

  def allowed_classes
    @allowed_classes ||= begin
      # make sure all classes are already loaded
      Rails.application.eager_load!

      classes = ObjectSpace.each_object(Class).select do |klass|
        [AudienceLimitable].any? { |concern| klass.included_modules.include?(concern) }
      end

      classes.index_by(&:name).freeze
    end
  end

  def class_for(name)
    klass = allowed_classes[name.to_s.classify]
    return nil if klass.blank?

    # Fix single-table inheritance. klass.find must be done in the super class
    sklass = klass.superclass
    sklass == ApplicationRecord ? klass : sklass
  end

  def allowed?(name)
    allowed_classes[name.to_s.classify].present?
  end
end
