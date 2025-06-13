# frozen_string_literal: true

class PocsController < ApplicationController
  # This POC was meant to shows how turbo_stream.replace works all the times while
  # turbo_stream.update only works the first time. In fact, when it updates the
  # element, it adds css classes like `turbo-replace-enter` or `turbo-replace-exit`
  # and, as soon as those classes are present, the next replace/update does not
  # works. If the class is removed manually, then the update/replace works again
  # (only once in the case of update).
  # ==> It turned out that this was due to a stupid mod for animations added to turbo
  def turboru
    respond_to do |format|
      format.html { render 'turboru', layout: 'zero' }
      format.turbo_stream do
        if params["replace"].present?
          render 'turboru_replace'
        else
          render 'turboru_update'
        end
      end
    end
  end

  def properties
    @profile = Profile.for_sciper "121769"
  end

  def property_update
    model_class = params[:model]
    model_params = send("#{model_class.parameterize}_params")
    @attribute = model_params.keys.first.to_sym
    klass = model_class.constantize
    @model = klass.find(params[:id])
    @model.update(model_params)
    if @model.update(model_params)
      flash.now[:success] = ".update"
    else
      flash.now[:error] = ".update"
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:personal_web_url, :personal_phone)
  end
end
