# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  connects_to database: { writing: :people, reading: :people }
end
