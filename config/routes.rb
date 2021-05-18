Rails.application.routes.draw do
  resources :budgets
  resources :transactions
  resources :allowances
end
