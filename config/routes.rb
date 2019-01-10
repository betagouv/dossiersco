Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'accueil#index'
  post '/identification', to: 'accueil#identification'
  get '/accueil', to: 'accueil#accueil'

  get '/eleve', to: 'accueil#get_eleve'
  post '/eleve', to: 'accueil#post_eleve'

  get '/famille', to: 'accueil#get_famille'
  post '/famille', to: 'accueil#post_famille'

  get '/validation', to: 'accueil#validation'
  post '/validation', to: 'accueil#post_validation'

  get '/administration', to: 'accueil#administration'
  post '/administration', to: 'accueil#post_administration'

  post '/deconnexion', to: 'accueil#deconnexion'

  get '/confirmation', to: 'accueil#confirmation'

  post '/satisfaction', to: 'accueil#satisfaction'
  post '/commentaire', to: 'accueil#commentaire'

  get '/pieces_a_joindre', to: 'accueil#pieces_a_joindre'
  post '/enregistre_piece_jointe', to: 'accueil#enregistre_piece_jointe'
  post '/pieces_a_joindre', to: 'accueil#post_pieces_a_joindre'

  get '/piece/:dossier_eleve/:code_piece/:s3_key', to: 'accueil#piece'

  get '/deconnexion', to: 'accueil#deconnexion'

  get '/stats', to: 'accueil#stats'

  get '/agent', to: 'inscriptions#agent'
  post '/agent', to: 'inscriptions#post_agent'

  get '/agent/liste_des_eleves', to: 'inscriptions#liste_des_eleves'

  get '/agent/import_siecle', to: 'inscriptions#new_import_siecle'
  post '/agent/import_siecle', to: 'inscriptions#import_siecle'

  get '/api/traiter_imports', to: 'inscriptions#declenche_traiter_imports'

  post '/agent/change_etat_fichier', to: 'inscriptions#change_etat_fichier'

  get '/agent/eleve/:identifiant', to: 'inscriptions#eleve'

  get '/agent/piece_attendues', to: 'inscriptions#pieces_attendues'
  post '/agent/piece_attendues', to: 'inscriptions#post_pieces_attendues'

  post '/agent/pdf', to: 'inscriptions#post_pdf'

  post '/agent/valider_inscription', to: 'inscriptions#valider_inscription'

  post '/agent/eleve_sortant', to: 'inscriptions#eleve_sortant'

  post '/agent/contacter_une_famille', to: 'inscriptions#contacter_une_famille'
end
