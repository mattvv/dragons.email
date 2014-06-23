Rails.application.routes.draw do
  resources :inbound
  resources :lists
  resources :emails

  root to: "lists#index"
end
