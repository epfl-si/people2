# frozen_string_literal: true

class LegacyController < ApplicationController
  protect_from_forgery
  before_action :set_sciper_and_email, only: %i[show0 show]
  before_action :set_show_data, only: %i[show0 show]
  layout 'legacy'

  def show0
    @page_title = "EPFL - #{@person.display_name}"
    respond_to do |format|
      format.html { render layout: 'legacy0' }
    end
  end

  def show
    @page_title = "EPFL - #{@person.display_name}"
    respond_to do |format|
      format.html { render layout: 'legacy' }
      format.vcf { render layout: false }
    end
  end

  private

  def set_sciper_and_email
    sciper_or_name = params[:sciper_or_name]
    @sciper = nil
    if sciper_or_name =~ /^\d{6}$/
      @sciper = sciper_or_name
      @email = Legacy::Email.find(@sciper)
    else
      @email = Legacy::Email.where('addrlog = ? OR addrlog LIKE ?', "#{sciper_or_name}@epfl.ch",
                                   "#{sciper_or_name}@epfl.%").first
      @sciper = @email.sciper unless @email.nil?
    end
  end

  def set_show_data
    set_sciper_and_email unless @sciper
    @person = Legacy::Person.find(@sciper)
    @affiliations = @person.full_accreds

    # @cv can be nil because not everybody can edit his personal page
    # @cv = Legacy::Cv.find(@sciper)
    @cv = Legacy::Cv.where(sciper: @sciper).first
    @editable = !@cv.nil? && @person.can_edit_profile?

    @ta = (Isa::Teaching.new(@sciper) if @person.possibly_teacher?)
    return unless @editable

    @tcv = @cv.translated_part(I18n.locale)
    bb = @tcv.boxes.visible.with_content.order(:position, :ordre)
    @boxes = {}
    %w[K B P R T].each do |k|
      @boxes[k] = bb.select { |b| b.position == k }
    end
    return if @boxes['B'].empty?

    @boxes['B'].first.label = '' if @boxes['B'].first.label == t('biography')
  end
end
