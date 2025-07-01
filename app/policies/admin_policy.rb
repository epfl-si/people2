# frozen_string_literal: true

class AdminPolicy < ActionPolicy::Base
  def manage?
    user.superuser?
  end
end
