
Rails.application.routes.draw do
  root "events#index"

  get "sign-in", to: "sessions#new", as: :sign_in

  get "up" => "rails/health#show", as: :rails_health_check
end
