Rails.application.routes.draw do
  get 'users/destroy'

  resources :users do
    resources :activities
    resources :relationships
  end

  root 'home#index'

  get 'home/profile'

  get 'auth/:provider/callback', to: 'sessions#create'

  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
end
