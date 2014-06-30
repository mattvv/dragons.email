Rails.application.routes.draw do
  resources :inbound
  resources :lists do
    resources :emails
  end
  resources :messages
  resources :emails do
    collection do
      post :import
    end
  end

  root to: "lists#index"
end
