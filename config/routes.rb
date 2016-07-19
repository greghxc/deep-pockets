Rails.application.routes.draw do
  namespace :api do
    resources :tokens
    resources :transactions, only: [:create, :show, :index, :edit]
    get 'transactions/:id/activities', to: 'transactions#activities'
  end
end
