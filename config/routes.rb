Rails.application.routes.draw do
  get '/health', to: 'health#show'

  resources :services, only: [:create] do
    get '/users/:user_id', to: 'services#services_for_user', on: :collection
    resources :versions, only: [:index, :create, :show] do
      get :latest, on: :collection
    end
  end
end
