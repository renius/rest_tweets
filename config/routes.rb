require 'sidetiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"
  resources :users do
    resources :tweets
  end
end
