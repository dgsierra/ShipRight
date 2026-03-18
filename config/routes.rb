Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "sessions" }

  # Dashboard namespace
  namespace :dashboard do
    resources :orders, only: %i[index show] do
      member do
        post :approve
        post :ship
        post :deliver
        post :cancel
      end
      collection do
        post :bulk_update
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root redirects to dashboard
  authenticated :user do
    root to: "dashboard/orders#index", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")
end
