Rails.application.routes.draw do
  get '/health', to: 'health#show'

  resources :services, only: [:show, :create] do
    resources :versions, only: :create
  end
end
