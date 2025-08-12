# frozen_string_literal: true

class ModelBoxSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    model_box = ModelBox.find(id)
    model_box.sync!
  end
end
