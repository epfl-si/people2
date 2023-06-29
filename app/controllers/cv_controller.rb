class CvController < ApplicationController
  protect_from_forgery
  before_action :set_sciper_and_email, only: [:show]
  before_action :set_show_data, only: [:show]
  layout "legacy"

  def show
    @page_title = "EPFL - #{@person.display_name}"
    respond_to do |format|
      format.html { render layout: 'legacy'  }
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
      @email = Legacy::Email.where("addrlog = ? OR addrlog LIKE ?", "#{sciper_or_name}@epfl.ch", "#{sciper_or_name}@epfl.%").first
      @sciper=@email.sciper unless @email.nil?
    end
  end

  def set_show_data
    set_sciper_and_email unless @sciper
    @person = Legacy::Person.find(@sciper)
    @affiliations = @person.full_accreds

    # @cv can be nil because not everybody can edit his personal page
    # @cv = Legacy::Cv.find(@sciper)
    @cv = Cv.where(id: @sciper).first
    @editable = !@cv.nil? && @person.can_edit_profile?

    # TODO: figure out why this does not work anymore. 
    # if @person.possibly_teacher?
    #   @ta = Isa::Teaching.new(@sciper)
    # else
    #   @ta = nil
    # end

    # TODO: would a sort of "PublicSection" class make things easier here ?
    #       keep in mind that here we only manage boxes but we will have 
    #       more content like awards, work experiences, infoscience pubs etc.
    #       that is not just a simple free text box with a title.
    if @editable
      # get sections that contain at least one box in the current locale 
      @cvlocale = @cv.force_lang || I18n.locale
      @contact_sections = Section.includes(:boxes).where(
        zone: "contact", 
        "boxes.cv_id": @cv.id, 
        "boxes.visible": true, 
        "boxes.locale": @cvlocale
      ).order(:position, "boxes.position").select{|s| s.have_content? }
      @main_sections = Section.includes(:boxes).where(
        zone: "main", 
        "boxes.cv_id": @cv.id, 
        "boxes.visible": true, 
        "boxes.locale": @cvlocale
      ).order(:position, "boxes.position").select{|s| s.have_content?}
    end    
  end
end
