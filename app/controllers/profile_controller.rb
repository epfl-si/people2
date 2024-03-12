# frozen_string_literal: true

class ProfileController < ApplicationController
  protect_from_forgery
  # before_action :set_sciper_and_email, only: [:show]
  before_action :set_show_data, only: [:show]
  layout 'legacy'

  def show
    @page_title = "EPFL - #{@person.display_name}"
    respond_to do |format|
      format.html do
        ActiveSupport::Notifications.instrument('profile_controller_render') do
          render layout: 'legacy'
        end
      end
      format.vcf { render layout: false }
    end
  end

  private

  # TODO
  def set_audience
    # @audience = rand(0..3)
    @audience = 3
  end

  def set_person; end

  def set_show_data
    set_audience

    ActiveSupport::Notifications.instrument('set_show_data_part_1') do
      @person = Person.find(params[:sciper_or_name])
      @sciper = @person.sciper

      @admin_data = @audience > 1 ? @person.admin_data : nil
    end

    ActiveSupport::Notifications.instrument('set_show_data_part_2') do
      @profile = @person.profile
      @editable = @person.can_edit_profile? && @profile.present?

      @accreds = @person.accreds.select(&:visible?).sort
    end

    ActiveSupport::Notifications.instrument('set_show_data_part_3') do
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
    end

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.
    return unless @editable

    @courses = @profile.courses.group_by { |c| c.t_title(I18n.locale) }

    ActiveSupport::Notifications.instrument('set_show_data_part_4') do
      @photo = @profile.photo if @profile.photo.present?

      @visible_socials = @profile.socials.for_audience(@audience)

      # User's provided data (boxes) is coerced to @profile.force_lang locale
      @cvlocale = @profile.force_lang || I18n.locale
      logger.debug("sciper: #{@sciper} locale=#{I18n.locale} cvlocale=#{@cvlocale}")
    end

    ActiveSupport::Notifications.instrument('set_show_data_part_5') do
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
end
