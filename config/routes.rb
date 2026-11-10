
Rails.application.routes.draw do
  root "events#index"

  get "up" => "rails/health#show", as: :rails_health_check
  get "sign-in", to: "sessions#new", as: :sign_in

  resource :vote, only: [ :create ]
end
