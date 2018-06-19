Rails.application.routes.draw do
  root 'application#index'

  namespace :heroku do
    resources :resources, only: [:create, :update, :destroy]
    resources :dashboard, only: [:show]
  end

  namespace :sso do
    resource :login, only: [:create]
  end
end
