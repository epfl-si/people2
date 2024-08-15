# frozen_string_literal: true

class BackendController < ApplicationController
  protect_from_forgery
  before_action :authenticate_user!

  def new_session_path(_scope)
    new_user_session_path
  end
end
