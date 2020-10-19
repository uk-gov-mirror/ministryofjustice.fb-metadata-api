Rails.application.routes.draw do
  get '/health', to: 'health#show'

  resources :services, only: [:create] do
    resources :versions, only: :create do
      get :latest, on: :collection
    end
  end
end
