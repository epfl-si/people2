# frozen_string_literal: true

Rails.application.routes.draw do
  # Custom Error Pages
  match '/500', via: :all, to: 'errors#internal_server_error'
  match '/401', via: :all, to: 'errors#unauthorized'
  match '/403', via: :all, to: 'errors#forbidden'
  match '/404', via: :all, to: 'errors#not_found'
  match '/422', via: :all, to: 'errors#unprocessable_content'

  unless Rails.configuration.enable_direct_uploads
    match "/rails/active_storage/direct_uploads", to: proc { [404, {}, ['Not Found']] }, via: :all
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # namespace :oidc do
  #   # URL prefix for controllers in this section is `/oidc/`, and
  #   # controllers live in module `OIDC` (not "Oidc"), thanks to
  #   # the `inflect.acronym("OIDC")` stanza in ./initializers/inflections.rb
  #   get 'config', to: 'frontend_config#get' # i.e. OIDC::FrontendConfigController#get
  # end
  # mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  # post '/graphql', to: 'graphql#execute'

  # resource :session
  # resources :passwords, param: :token
  resource :session, only: %i[new destroy create]
  get "/auth/oidc_callback", to: "sessions#create", as: "oidc_callback"

  resources :profiles, only: %i[edit update show] do
    resources :rich_text_boxes, shallow: true
    resources :index_boxes, shallow: true
    resources :boxes, shallow: true, except: %i[index]
    resources :socials, shallow: true
    resources :achievements, shallow: true
    resources :awards, shallow: true
    resources :educations, shallow: true
    resources :experiences, shallow: true
    resources :infosciences, shallow: true
    resources :publications, shallow: true
    resources :pictures, shallow: true
    resources :accreds, shallow: true, only: %i[index show update]
    member do
      patch :set_favorite_picture
      get 'name_change/select', to: 'profiles#name_change_select', as: :name_change_select
    end
  end
  get 'profiles/:profile_id/sections/:section_id/boxes', to: 'boxes#index', as: 'profile_section_boxes'
  get 'people/:sciper/profile/new', to: 'profiles#new', as: 'new_person_profile'

  patch 'visibility/:model/:id', to: 'visibility#update', as: 'visibility'

  resources :accreditations, only: [] do
    resources :function_changes, shallow: true, except: %i[index]
  end

  # put 'boxes/:id/toggle', to: 'boxes#toggle', as: 'toggle_box'
  # put 'socials/:id/toggle', to: 'socials#toggle', as: 'toggle_social'
  # put 'awards/:id/toggle', to: 'awards#toggle', as: 'toggle_award'
  # put 'educations/:id/toggle', to: 'educations#toggle', as: 'toggle_education'
  # put 'experiences/:id/toggle', to: 'experiences#toggle', as: 'toggle_experience'
  # put 'publications/:id/toggle', to: 'publications#toggle', as: 'toggle_publication'

  resources :names, only: %i[index show update]

  namespace :api do
    # namespace /api/v0 is actually /cgi-bin via traefik rewrite
    namespace :v0 do
      get '/wsgetPhoto', to: 'legacy_webservices#photo'
      get '/wsgetpeople', to: 'legacy_webservices#people'
      get '/prof_awards', to: 'legacy_webservices#awards'
    end
  end

  # profile#show using _legacy_ layout
  get '/:sciper_or_name', to: 'people#show', as: 'person',
                          constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/ }

  if Rails.configuration.enable_adoption
    resources :adoptions, only: %i[update]
    get '/:sciper_or_name/preview',
        to: 'people#preview',
        as: 'preview',
        constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/ }
  end

  namespace :admin do
    resources :translations, except: %i[new create destroy]
    patch 'translations/:id/autotranslate', to: 'translations#autotranslate', as: 'translation_autotranslate'
    patch 'translations/:id/propagate', to: 'translations#propagate', as: 'translation_propagate'
  end

  if Rails.env.production?
    root 'pages#homepage'
  else
    get '/pocs/turboru', to: 'pocs#turboru'
    get '/homepage', to: 'pages#homepage'
    root 'pages#devindex'
  end
end
