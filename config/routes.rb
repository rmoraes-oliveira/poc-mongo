Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#index"

  # Dashboard routes
  get '/dashboard', to: 'dashboard#index'
  get '/dashboard/:manufacturer_id', to: 'dashboard#index', as: :dashboard_manufacturer
  get '/api/regional-sales', to: 'dashboard#regional_sales'
  get '/api/state-sales/:region', to: 'dashboard#state_sales'
  get '/api/state-seasonality/:state', to: 'dashboard#state_seasonality'
  get '/api/regional-seasonality/:region', to: 'dashboard#regional_seasonality'
  get '/api/category-comparison/:manufacturer_id', to: 'dashboard#category_comparison'
end
