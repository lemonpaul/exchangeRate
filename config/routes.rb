Rails.application.routes.draw do
  get 'welcome/index'
  post 'welcome/index'
  require 'sidekiq/web'
  require 'sidekiq/api'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'
  resources :rates
  resources :triggers

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
