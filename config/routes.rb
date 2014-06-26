Rails.application.routes.draw do
  resources :inbound
  resources :lists do
    resources :emails
  end
  resources :emails

  root to: "lists#index"
end
