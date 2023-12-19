# frozen_string_literal: true

module Types
  class ArtistType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :email, String
    field :first_name, String
    field :id, ID, null: false
    field :last_name, String
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
