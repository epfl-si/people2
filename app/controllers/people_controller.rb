# frozen_string_literal: true

class PeopleController < ApplicationController
  # protect_from_forgery
  allow_unauthenticated_access only: [:show]
  layout 'public'

  def show
    check_for_redirect and return
    set_base_data
    Rails.configuration.enable_adoption and proxy_orphan and return

    set_show_data
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
        # Only someone that can edit the profile, is allowed to preview it
        @person = Person.find(params[:sciper_or_name])
        authorize!(@person, to: :update?)
        # The first time a profile is previewed we consider it as fully migrated
        # and actually waiting for adoption. This will enable the option of
        # reverting to almost default profiles (keeping only the accred prefs
        # base profile)
        @adoption.previewed = true
        @adoption.save
        @special_partial = 'adopt'
        set_base_data
        set_show_data
        render 'people/show'
      else
        redirect_to action: :show
      end
    end

    # serve the legacy profile when the new one is yet to be adopted (orphan)
    def proxy_orphan
      m = Adoption.not_yet(params[:sciper_or_name])
      if m.present?
        respond_to do |format|
          format.html do
            adh = PeopleController.render(
              partial: 'people/admin_data_for_legacy',
              assigns: { admin_data: @admin_data, authenticated: authenticated? }
            )
            render plain: m.content(I18n.locale, admin_data_html: adh)
          end
          # we assume vcf from new app are ok
          format.vcf do
            set_base_data
            render layout: false
          end
        end
        true
      else
        false
      end
    end
  end

  private

  def check_for_redirect
    r = SpecialRedirect.for_sciper_or_name(params[:sciper_or_name])
    if r.present?
      redirect_to(r.url, allow_other_host: true)
      true
    else
      false
    end
  end

  def set_base_data
    @person ||= Person.find(params[:sciper_or_name])
    raise ActiveRecord::RecordNotFound if @person.blank?
    # We could use policy but 404 it is more appropriate than a 401 in this case
    # because the problem is not the visitor but the profile
    # authorize! @person, to: :show?
    raise ActionController::RoutingError, 'Not Found' unless @person.visible_profile? || allowed_to?(:edit?, @person)

    @sciper = @person&.sciper
    compute_audience(@sciper)

    @accreds = @person.accreditations
    if @accreds.count > 1
      @accreds.select { |a| a.visible_by?(Current.audience) }.sort
      raise ActiveRecord::RecordNotFound if @accreds.empty?
    else
      raise ActiveRecord::RecordNotFound unless @accreds.first&.botweb?
    end

    # @profile will be null if @person is not allowed to have a profile
    @profile = @person&.profile!

    @admin_data = allowed_to?(:show_admin_data?, @person) ? @person.admin_data : nil

    Current.gender = @person.gender

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.

    # take into account profile's enaled languages
    Current.translations = @profile&.translations || I18n.available_locales
  end

  def set_show_data
    @page_title = "EPFL - #{@person.name.display}"

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
