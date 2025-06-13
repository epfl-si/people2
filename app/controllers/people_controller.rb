# frozen_string_literal: true

class PeopleController < ApplicationController
  # protect_from_forgery
  allow_unauthenticated_access only: [:show]
  layout 'public'

  def show
    r = SpecialRedirect.for_sciper_or_name(params[:sciper_or_name])
    redirect_to(r.url, allow_other_host: true) and return if r.present?

    if Rails.configuration.enable_adoption
      m = Adoption.not_yet(params[:sciper_or_name])
      if m.present?
        respond_to do |format|
          format.html { render plain: m.content(I18n.locale) }
        end
        # render plain: content
        # # render body: content
        return
      end
    end

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

  # GET /people/SCIPER/admin_data
  def admin_data
    @person = Person.find(params[:sciper])
  end

  # TODO: remove after migration from legacy
  if Rails.configuration.enable_adoption
    def preview
      @adoption = Adoption.not_yet(params[:sciper_or_name])
      if @adoption
        @special_partial = 'adopt'
        set_show_data
        render 'people/show'
      else
        redirect_to action: :show
      end
    end
  end

  private

  def set_show_data
    # ActiveSupport::Notifications.instrument('set_base_data') do
    # end
    @person = Person.find(params[:sciper_or_name])
    raise ActiveRecord::RecordNotFound if @person.blank?

    @sciper = @person&.sciper
    compute_audience(@sciper)

    @accreds = @person.accreditations.select { |a| a.visible_by?(Current.audience) }.sort
    raise ActiveRecord::RecordNotFound if @accreds.empty?

    # @profile will be null if @person is not allowed to have a profile
    @profile = @person&.profile!

    @admin_data = Current.audience > AudienceLimitable::WORLD ? @person.admin_data : nil

    Current.gender = @person.gender

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.

    # take into account profile's enaled languages
    Current.translations = @profile.translations

    # teachers are supposed to all have a profile
    @ta = Isa::Teaching.new(@sciper) if @person.possibly_teacher?
    if @ta.present?
      @current_phds = @ta.phd&.select(&:current?)
      @past_phds = @ta.phd&.select(&:past?)
      @teachings = @ta.primary_teaching + @ta.secondary_teaching + @ta.doctoral_teaching
    else
      @current_phds = nil
      @past_phds = nil
      @teachings = nil
    end

    @courses = @person.courses.group_by { |c| c.t_title(I18n.locale) }

    return unless @profile

    @profile_picture = @profile.photo(Current.audience).image if @profile.photo&.image&.attached?
    # @profile_picture = @profile.photo.image if @profile.show_photo && @profile.photo.image.attached?
    @visible_socials = @profile.socials.for_audience(Current.audience)

    # get sections that contain at least one box in the chosen locale
    unsorted_boxes = @profile.boxes.for_audience(Current.audience).includes(:section).select do |b|
      b.content_for?(Current.audience)
    end
    @boxes = unsorted_boxes.sort do |a, b|
      [a.section.position, a.position] <=> [b.section.position, b.position]
    end
    @boxes_by_section = @boxes.group_by(&:section)

    @contact_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "contact" }
    @main_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "main" }
    @side_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "side" }

    # @contact_sections = []
    # @main_sections = []
  end
end
