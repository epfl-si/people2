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
  mount Yabeda::Prometheus::Exporter => "/metrics"

  get "myip" => "api/ip#index"

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
    resources :usual_name_changes, only: %i[new create]
    resources :usual_name_requests, only: %i[new create]
    member do
      patch :set_favorite_picture
      patch :reset_field
    end
  end
  get 'profiles/:profile_id/sections/:section_id/boxes', to: 'boxes#index', as: 'profile_section_boxes'
  get 'people/:sciper_or_name/profile/new', to: 'profiles#new', as: 'new_person_profile',
                                            constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/i }

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
      get '/wsgetPhoto', to: 'photos#show'
      get '/wsgetpeople', to: 'people#index'
      get '/prof_awards', to: 'awards#index'
      get '/wsgetcours', to: 'courses#wsgetcours'
      get '/getCours', to: 'courses#getcourse'
    end
  end
  # The following aliases should be managed by the webserver but we keep them just in case
  get '/cgi-bin/prof_awards', to: 'api/v0/awards#index'
  get '/cgi-bin/wsgetpeople', to: 'api/v0/people#index'
  get '/cgi-bin/wsgetPhoto', to: 'api/v0/photos#show'
  get '/cgi-bin/wsgetcours', to: 'api/v0/courses#wsgetcours'
  get '/cgi-bin/getCours', to: 'api/v0/courses#getcourse'

  # See comment in controller
  get '/cgi-bin/people', to: 'people#super_legacy_show'
  get '/api/v0/people', to: 'people#super_legacy_show'

  # Retrocompatibility with applications having saved the old link or
  # generating it on the fly (being quite easy to guess)
  get '/private/common/photos/links/:sciper.jpg', to: 'api/v0/photos#show'

  # THE public profile route
  get '/:sciper_or_name', to: 'people#show', as: 'person',
                          constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/i }

  namespace :help do
    get 'boxes/:id', to: 'helps#box', as: 'box'
    get 'sections/:id', to: 'helps#section', as: 'section'
    get 'ui/:label', to: 'helps#ui', as: 'ui'
  end

  namespace :admin do
    get '/', to: 'dashboards#index', as: 'dashboard'
    get '/dashboards/:id', to: 'dashboards#show', as: 'dashboard_panel'
    resources :model_boxes, except: %i[new create destroy]
    resources :sections, except: %i[new create destroy] do
      resources :model_boxes, only: %i[index update], controller: 'sections/model_boxes'
    end
    resources :selectable_properties, except: %i[new create destroy show]
    resources :special_options, except: %i[show]
    resources :motds
    resources :service_auths
    resources :service_auths_mini, controller: "service_auths", type: "ServiceAuthMini", as: 'service_auth_mini'
    if Rails.env.development?
      resources :translations, except: %i[new create destroy] do
        patch 'autotranslate', on: :member
        patch 'propagate', on: :member
        collection do
          get 'apply'
          get 'export'
        end
      end
    end
    resources :versions, only: %i[index show]
  end
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  mount SolidErrors::Engine, at: "/admin/errors"

  if Rails.configuration.enable_adoption
    resources :adoptions, only: %i[update]
    get '/:sciper_or_name/preview',
        to: 'people#preview',
        as: 'preview',
        constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/ }
    # compatibility with legacy routes
    get '/:sciper_or_name/vcard',
        to: redirect("/%{sciper_or_name}.vcf"),
        constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/ }
  end
  get '/:sciper_or_name/admin_data',
      to: 'people#admin_data',
      as: 'admin_data',
      constraints: { sciper_or_name: /([0-9]{6})|([a-z-]+\.[a-z-]+)/ }

  if Rails.env.production?
    root 'pages#homepage'
  else
    get '/pocs/turboru', to: 'pocs#turboru'
    get '/pocs/reload', to: 'pocs#reload'
    get '/pocs/time', to: 'pocs#time'
    get '/homepage', to: 'pages#homepage'
    root 'pages#devindex'
  end
end
