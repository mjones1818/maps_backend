Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :styles
  get 'get_map', to: 'styles#get_map'
  get 'rcm', to: 'styles#rcm'
  get 'get_colors', to: 'colors#get_colors'
  get 'save_style/:style_id', to: 'styles#save_style'
end
