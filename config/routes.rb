Rails.application.routes.draw do
  get '/health', to: 'health#show'

  resources :services, only: :create
end
