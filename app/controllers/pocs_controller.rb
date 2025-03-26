# frozen_string_literal: true

class PocsController < ApplicationController
  # This POC shows how turbo_stream.replace works all the times while
  # turbo_stream.update only works the first time. In fact, when it updates the
  # element, it adds css classes like `turbo-replace-enter` or `turbo-replace-exit`
  # and, as soon as those classes are present, the next replace/update does not
  # works. If the class is removed manually, then the update/replace works again
  # (only once in the case of update).
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
end
