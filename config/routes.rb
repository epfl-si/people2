Rails.application.routes.draw do
  namespace :oidc do
    # URL prefix for controllers in this section is `/oidc/`, and
    # controllers live in module `OIDC` (not "Oidc"), thanks to
    # the `inflect.acronym("OIDC")` stanza in ./initializers/inflections.rb
    get "config", to: "frontend_config#get"  # i.e. OIDC::FrontendConfigController#get
  end

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/cv0/:sciper_or_name', to: 'legacy#show0', as: "person0",
      :constraints => { :sciper_or_name => /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  get '/cv1/:sciper_or_name', to: 'legacy#show', as: "person",
      :constraints => { :sciper_or_name => /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  get '/cv2/:sciper_or_name', to: 'cv#show', as: "cv",
      :constraints => { :sciper_or_name => /([0-9]{6})|([a-z]+\.[a-z]+)/ }

  # Defines the root path route ("/")
  root "application#homepage"
end
