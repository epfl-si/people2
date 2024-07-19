# frozen_string_literal: true

Rails.application.routes.draw do
  # Custom Error Pages
  match '/500', via: :all, to: 'errors#internal_server_error'
  match '/401', via: :all, to: 'errors#unauthorized'
  match '/403', via: :all, to: 'errors#forbidden'
  match '/404', via: :all, to: 'errors#not_found'
  match '/422', via: :all, to: 'errors#unprocessable_content'

  # namespace :oidc do
  #   # URL prefix for controllers in this section is `/oidc/`, and
  #   # controllers live in module `OIDC` (not "Oidc"), thanks to
  #   # the `inflect.acronym("OIDC")` stanza in ./initializers/inflections.rb
  #   get 'config', to: 'frontend_config#get' # i.e. OIDC::FrontendConfigController#get
  # end

  # mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  # post '/graphql', to: 'graphql#execute'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :profiles, only: %i[edit update] do
    resources :boxes, shallow: true
    resources :socials, shallow: true
    resources :awards, shallow: true
    resources :educations, shallow: true
    resources :experiences, shallow: true
    resources :pictures, shallow: true, only: %i[index create destroy]
    resources :accreds, shallow: true, only: %i[index show update]
    member do
      patch :set_favorite_picture
    end
  end
  put 'boxes/:id/toggle', to: 'boxes#toggle', as: 'toggle_box'
  put 'socials/:id/toggle', to: 'socials#toggle', as: 'toggle_social'
  put 'awards/:id/toggle', to: 'awards#toggle', as: 'toggle_award'
  put 'educations/:id/toggle', to: 'educations#toggle', as: 'toggle_education'
  put 'experiences/:id/toggle', to: 'experiences#toggle', as: 'toggle_experience'
  put 'accreds/:id/toggle', to: 'accreds#toggle', as: 'toggle_accred'
  put 'accreds/:id/toggle_address', to: 'accreds#toggle_addr', as: 'toggle_addr_accred'
  get 'people/:sciper/profile/new', to: 'profiles#new', as: 'new_person_profile'

  resources :names, only: %i[index show update]

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
