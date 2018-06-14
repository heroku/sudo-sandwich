Rails.application.routes.draw do
  root 'application#index'

  namespace :heroku do
    resources :resources, only: [:create, :update, :destroy]
  end
end
