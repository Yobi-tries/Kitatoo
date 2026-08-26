Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :artists, only: [:index, :show]

  resource :artist_profile, only: [:new, :create, :edit, :update] do
    resources :addresses, only: [:index, :create, :update, :destroy]
    resources :availabilities, only: [:index, :create, :update, :destroy]
    resources :portfolio_items, only: [:create]
  end

  resources :artist_profiles, only: [] do
    resources :availabilities, only: [:index], as: :public_availabilities
    resources :conversations, only: [:new, :create]
    resources :bookings, only: [:create]
  end

  resources :conversations, only: [:index, :show] do
    resources :messages, only: [:create]
  end

  resources :bookings, only: [] do
    patch :confirm, on: :member
  end

  resources :tattoo_generations, only: [:new, :create]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
