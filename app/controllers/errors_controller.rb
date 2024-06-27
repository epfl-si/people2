# frozen_string_literal: true

# TODO: I am not sure that it makes sense to have all the engine instead of
# just static html pages in /public as it is the standard...
# The idea were to have a way to produce error pages with more informations but,
# since it needs a redirect, we have no informatinos ti provide.
# For the moment I keep it like this so that it is easier to style.
class ErrorsController < ApplicationController
  layout 'error'

  def internal_server_error
    render status: :internal_server_error
  end

  def unauthorized
    render status: :unauthorized
  end

  def forbidden
    render status: :forbidden
  end

  def not_found
    render status: :not_found
  end
end
