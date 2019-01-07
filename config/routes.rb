Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'accueil#index'
  post 'identification', to: 'accueil#identification'
  get '/accueil', to: 'accueil#accueil'
end
