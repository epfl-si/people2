# frozen_string_literal: true

json.extract! accred, :id, :position, :visibility, :address_visibility
json.url accred_url(accred, format: :json)
