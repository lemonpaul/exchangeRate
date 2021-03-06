Rails.application.routes.draw do
  get 'history/index'
  get 'welcome/index'
  get 'welcome/show'
  get 'rates/forecast'
  post 'triggers/update'
  post 'welcome/index'
  post 'logs/update'
  require 'sidekiq/web'
  require 'sidekiq/api'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'
  resources :rates
  resources :triggers
  resources :logs
  resources :charts

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
