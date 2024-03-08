# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :oidc do
    # URL prefix for controllers in this section is `/oidc/`, and
    # controllers live in module `OIDC` (not "Oidc"), thanks to
    # the `inflect.acronym("OIDC")` stanza in ./initializers/inflections.rb
    get 'config', to: 'frontend_config#get' # i.e. OIDC::FrontendConfigController#get
  end

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # This uses legacy_controller with the old legacy0 layout
  get '/cv0/:sciper_or_name', to: 'legacy#show0', as: 'person0',
                              constraints: { sciper_or_name: /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  # This uses legacy_controller with the legacy layout
  get '/cv1/:sciper_or_name', to: 'legacy#show', as: 'person',
                              constraints: { sciper_or_name: /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  # This uses cv_controller (therefore privileges new models instead
  # of all legacy) with the legacy layout
  get '/cv2/:sciper_or_name', to: 'profile#show', as: 'profile',
                              constraints: { sciper_or_name: /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  namespace :api do
    # namespace /api/v0 is actually /cgi-bin via traefik rewrite
    namespace :v0 do
      get '/wsgetPhoto', to: 'legacy#photo'
    end
  end

  # if Rails.env.development?
  #   match '/fakeapi/*other', to: 'fake_api#cache', via: [:get]

  #   # # useful queries:
  #   # #   firstname=giovanni&lastname=cangiani
  #   # #   persid=121769
  #   # #   persid=121769,116080
  #   # #   uinitid=13030         # does not work
  #   # get '/fakeapi/persons/:sciper', to: 'fake_api#person_by_sciper'
  #   # get '/fakeapi/persons',         to: 'fake_api#persons'
  #   # get '/fakeapi/accreds/:sciper', to: 'fake_api#accred_by_sciper'
  #   # get '/fakeapi/accreds',         to: 'fake_api#accreds'
  # end

  # Defines the root path route ("/")
  root 'application#homepage'
end
