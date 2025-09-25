# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class Teachership < ApplicationRecord
  establish_connection :work

  belongs_to :course
end
