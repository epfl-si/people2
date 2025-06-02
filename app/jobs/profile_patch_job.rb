# frozen_string_literal: true

class ProfilePatchJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    APIPersonUpdater.call(args)
  end
end
