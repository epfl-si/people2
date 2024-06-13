# frozen_string_literal: true

json.extract! accred, :id, :position, :hidden, :hidden_addr
json.url accred_url(accred, format: :json)
