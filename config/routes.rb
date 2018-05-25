Rails.application.routes.draw do
  namespace :heroku do
    resources :resources, only: [:create]
  end
end
