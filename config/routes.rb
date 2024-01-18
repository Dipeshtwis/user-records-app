Rails.application.routes.draw do
  root "users#index"

  resources :users
  get 'daily_records_report', to: 'daily_records#daily_records_report'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
