# frozen_string_literal: true

class AddCategoryToEducation < ActiveRecord::Migration[8.0]
  def up
    add_reference :educations, :category
    o = SelectableProperty.where(property: "education_category", label: "other").first
    if o.nil?
      o = SelectableProperty.create(
        property: "education_category",
        label: "other",
        name_en: "Other",
        name_fr: "Other",
        name_it: "Other",
        name_de: "Other"
      )
    end
    # rubocop:disable Rails/SkipsModelValidations
    Education.update_all(category_id: o.id)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_reference :educations, :category
  end
end

# SelectableProperty.create([
#   {
#     label: "postdoc",
#     name_en: "Post Doc",
#     name_fr: "Post Doc",
#     name_it: "Post-dottorato",
#     name_de: "Post Doc",
#     property: "education_category",
#   },
#   {
#     label: "phd",
#     name_en: "Ph.D.",
#     name_fr: "Doctorat",
#     name_it: "Dottorato",
#     name_de: "Ph.D.",
#     property: "education_category",
#   },
#   {
#     label: "master",
#     name_en: "Master",
#     name_fr: "Master",
#     name_it: "Master",
#     name_de: "Master",
#     property: "education_category",
#   },
#   {
#     label: "bachelor",
#     name_en: "Bachelor",
#     name_fr: "Bachelor",
#     name_it: "Bachelor",
#     name_de: "Bachelor",
#     property: "education_category",
#   },
#   {
#     label: "matu",
#     name_en: "High School",
#     name_fr: "Maturité",
#     name_it: "Maturità",
#     name_de: "High School",
#     property: "education_category",
#   },
#   {
#     label: "cfc",
#     name_en: "CFC",
#     name_fr: "CFC",
#     name_it: "CFC",
#     name_de: "CFC",
#     property: "education_category",
#   },
# ])
