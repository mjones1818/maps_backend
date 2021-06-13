Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :styles
  get 'get_map', to: 'styles#get_map'
  get 'rcm', to: 'styles#rcm'
end
