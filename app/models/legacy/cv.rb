# frozen_string_literal: true

module Legacy
  class Cv < Legacy::BaseCv
    self.table_name = 'common'
    self.primary_key = 'sciper'

    # has_one :naming, class_name: 'Naming', foreign_key: 'sciper'

    # personal data is stored in two parts.
    # This class is the language independent (common) part
    # TranslatedCv is instead the language-dependent part
    has_many :translations, class_name: 'TranslatedCv', foreign_key: 'sciper', dependent: :destroy, inverse_of: false
    has_many :boxes, class_name: 'Box', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv

    has_many :achievements,   class_name: 'Achievement', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv
    has_many :educations,     class_name: 'Education', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv
    has_many :experiences,    class_name: 'Experience', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv
    has_many :publications,   class_name: 'Publication', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv
    has_many :social_ids,     class_name: 'SocialId', foreign_key: 'sciper', dependent: :destroy, inverse_of: :cv
    has_many :teaching_activities, class_name: 'TeachingActivity', foreign_key: 'sciper', dependent: :destroy,
                                   inverse_of: :cv

    # has_one  :account, :class_name => "Account", :foreign_key => "sciper"
    # has_many :offices, :class_name => "Office", :foreign_key => "sciper"
    # has_many :postal_addresses, :class_name => "PostalAddress", :foreign_key => "sciper"
    # has_many :accreds, :class_name => "Accreditation", :foreign_key => "persid"
    # This does not work. I think because it is missing the class for
    # Accreditation and looks for the accreds table in dinfo db
    # has_and_belongs_to_many :units, :join_table => "accreds",
    #        :foreign_key => "persid", :association_foreign_key => "unitid"
    # strftime is needed because we had to cast all datetimes into strings
    # explicit table name needed because col name is duplicate hence query ambiguous

    # TODO
    def photo_url
      'https://via.placeholder.com/400'
    end

    def show_birthday?
      datenaiss_show == '1'
    end

    def show_photo?
      photo_show == '1'
    end

    def any_publication?
      publications.present?
    end

    # TODO: use default language config for fallback
    def translated_part(lang)
      translations.where(cvlang: lang).first || translated_part.where(cvlang: defaultcv).first
    end

    def visible_social_ids
      # needs to be sorted after db fetch because most of the "ordre" entries
      # are NULL. Therefore, we mostly sort by the default order
      social_ids.where("id_show = '1' AND content IS NOT NULL").sort { |a, b| a.order <=> b.order }
    end

    # forward all getters that cannot be found to self.data (common table)
    # def method_missing(method_id, *arguments, &block)
    #   if self.data
    #     if self.data.respond_to?(method_id)
    #       self.data.send(method_id, *arguments)
    #     else
    #       super
    #     end
    #   else
    #     # in some case self.data is nil (e.g. when the user haven't edited his page yet)
    #     nil
    #   end
    # end
  end
end
