# frozen_string_literal: true

class ProfileController < ApplicationController
  protect_from_forgery
  # before_action :set_sciper_and_email, only: [:show]
  before_action :set_show_data, only: [:show]
  layout 'legacy'

  def show
    @page_title = "EPFL - #{@person.display_name}"
    respond_to do |format|
      format.html { render layout: 'legacy' }
      format.vcf { render layout: false }
    end
  end

  private

  def set_person; end

  def set_show_data
    @person = Person.find(params[:sciper_or_name])
    @sciper = @person.sciper

    @profile = @person.profile
    @editable = @person.can_edit_profile? && @profile.present?

    @accreds = @person.accreds.select(&:visible?).sort

    @ta = (Isa::Teaching.new(@sciper) if @person.possibly_teacher?)

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.
    return unless @editable

    @visible_socials = @profile.socials.select(&:visible?)

    # get sections that contain at least one box in the current locale
    @cvlocale = @profile.force_lang || I18n.locale
    unsorted_boxes = @profile.boxes.visible.includes(:section).select do |b|
      b.content?(@cvlocale)
    end
    @boxes = unsorted_boxes.sort do |a, b|
      [a.section.position, a.position] <=> [b.section.position, b.position]
    end
    @boxes_by_section = @boxes.group_by(&:section)

    @contact_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "contact" }
    @main_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "main" }

    # @contact_sections = []
    # @main_sections = []
  end
end
