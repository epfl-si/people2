# frozen_string_literal: true

module Legacy
  class TranslatedCv < Legacy::BaseCv
    self.table_name = 'cv'
    self.primary_key = 'sciper'

    # has_many :boxes, ->(object) { where cvlang: object.cvlang },
    #          class_name: 'Box', foreign_key: 'sciper', dependent: :destroy
    # has_many :publication_boxes, lambda { |object|
    #     where cvlang: object.cvlang
    #   }, class_name: 'PublicationBox', foreign_key: 'sciper', inverse_of: false
    # has_many :infosciences, lambda { |object|
    #     where cvlang: object.cvlang
    #   }, class_name: 'Infoscience', foreign_key: 'sciper', inverse_of: false

    def publication_boxes
      @publication_boxes ||= PublicationBox.where(sciper: sciper, cvlang: cvlang)
    end

    def infosciences
      @infosciences ||= Infoscience.where(sciper: sciper, cvlang: cvlang)
    end

    def title
      titre
    end

    def visible_title?
      titre_show == '1' && titre.present?
    end

    def visible_expertise?
      expertise_show == '1' && expertise.present?
    end

    def any_publication?
      infosciences.present? or publication_boxes.present?
    end

    # def method_missing(method_id, *arguments, &block)
    #   if self.data.respond_to?(method_id)
    #     self.data.send(method_id, *arguments)
    #   else
    #     super
    #   end
    # end
  end
end
