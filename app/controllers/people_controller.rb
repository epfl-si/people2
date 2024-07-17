# frozen_string_literal: true

class PeopleController < ApplicationController
  # protect_from_forgery
  layout 'public'

  def show
    r = Redirect.for_sciper_or_name(params[:sciper_or_name])
    redirect_to(r.url, allow_other_host: true) and return if r.present?

    set_show_data

    @page_title = "EPFL - #{@person.name.display}"
    respond_to do |format|
      format.html do
        ActiveSupport::Notifications.instrument('profile_controller_render') do
          render
        end
      end
      format.vcf { render layout: false }
    end
  end

  private

  def set_show_data
    # ActiveSupport::Notifications.instrument('set_base_data') do
    # end
    @person = Person.find(params[:sciper_or_name])
    raise ActiveRecord::RecordNotFound if @person.blank?

    @accreds = @person.accreditations.select(&:visible?).sort
    raise ActiveRecord::RecordNotFound if @accreds.empty?

    @sciper = @person&.sciper
    # @profile will be null if @person is not allowed to have a profile
    @profile = @person&.profile!

    compute_audience(@sciper)
    @admin_data = @audience > 1 ? @person.admin_data : nil

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.
    return unless @profile

    # teachers are supposed to all have a profile
    @ta = Isa::Teaching.new(@sciper) if @person.possibly_teacher?
    if @ta.present?
      @current_phds = @ta.phd.select(&:current?)
      @past_phds = @ta.phd.select(&:past?)
      @teachings = @ta.primary_teaching + @ta.secondary_teaching + @ta.doctoral_teaching
    else
      @current_phds = nil
      @past_phds = nil
      @teachings = nil
    end
    @courses = @profile.courses.group_by { |c| c.t_title(I18n.locale) }

    @profile_picture = @profile.photo.image if @profile.photo&.image&.attached?
    # @profile_picture = @profile.photo.image if @profile.show_photo && @profile.photo.image.attached?
    @visible_socials = @profile.socials.for_audience(@audience)

    # TODO: should we simply redirect to the page with selected locale ? May
    #       be not because this is just for user provided content and not for
    #       automatic adata like accreds etc.
    # User's provided data (boxes) is coerced to @profile.force_lang locale
    @cvlocale = @profile.force_lang || I18n.locale
    logger.debug("sciper: #{@sciper} locale=#{I18n.locale} cvlocale=#{@cvlocale}")

    # get sections that contain at least one box in the chosen locale
    unsorted_boxes = @profile.boxes.for_audience(@audience).includes(:section).select do |b|
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
