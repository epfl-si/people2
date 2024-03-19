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

  resources :profiles, only: %i[edit create update] do
    resources :boxes
    resources :socials
    resources :awards
    resources :educations
    resources :experiences
    resources :profile_pictures
    resources :accred_prefs
  end

  namespace :api do
    # namespace /api/v0 is actually /cgi-bin via traefik rewrite
    namespace :v0 do
      get '/wsgetPhoto', to: 'legacy#photo'
    end
  end

  # profile#show using _legacy_ layout
  get '/:sciper_or_name', to: 'people#show', as: 'person',
                          constraints: { sciper_or_name: /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  if Rails.env.production?
    root 'application#homepage'
  else
    root 'application#devindex'
  end
end
