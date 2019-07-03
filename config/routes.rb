# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "accueil#index"

  resource :dossier_affelnet, only: [:create] do
    post :traiter
  end

  resource  :configuration, only: [:show]

  resource :contact_par_etat, only: [:new, :create]

  resources :etablissement, only: [] do
    member do
      get "fiches_infirmeries", to: "fiches_infirmeries#fiches_infirmeries"
      get "generation_fiches_infirmerie", to: "fiches_infirmeries#generation_fiches_infirmerie"
      get "convocations", to: "convocations#convocations"
      get "generation_convocations", to: "convocations#generation_convocations"
    end
  end

  namespace :configuration do
    resources :dossiers_eleve, only: [] do
      collection do
        put :changer_mef_destination
      end
    end

    resources :options_pedagogiques, except: [:show] do
      member do
        post "ajoute_option_au_mef"
        delete "enleve_option_au_mef"
      end
      collection do
        post "definie_abandonnabilite"
        post "definie_ouverte_inscription"
        get "liste"
      end
    end
    resources :mef

    resources :etablissements, expect: %i[destroy] do
      put "purge"
      post "relance_invitation_agent"
    end

    resources :agents do
      member do
        post "changer_etablissement"
      end
      get "activation"
    end
    resources :pieces_attendues, expect: [:show, :index]
    resource :exports, only: :[] do
      collection do
        get "export-options", defaults: { format: "xlsx" }
        get "export-siecle", defaults: { format: "xml" }
        post "export_pieces_jointes"
      end
    end
    resources :regimes_sortie, expect: [:index]
    resources :campagnes, only: [:index] do
      collection do
        get 'edit_accueil'
        get 'edit_demi_pension'
        patch 'update_campagne'
      end
    end

    resource :import_nomenclature, only: %i[new create]
  end

  get '/agent/mot_de_passe', to: "mot_de_passe_agent#new", as: 'new_mot_de_passe_agent'
  post '/agent/mot_de_passe', to: "mot_de_passe_agent#update", as: 'mot_de_passe_agent'

  resources :pieces_jointes, only: %i[create update show] do
    member do
      put "valider"
      put "refuser"
      put "annuler_decision"
    end
  end

  resources :agent_pieces_jointes, only: %i[create update]
  resources :tache_imports, only: %i[new create]
  resources :suivi, only: [:index] do
    collection do
      get 'etablissements_experimentateurs'
    end
  end

  namespace :api do
    resource :communes, only: :[] do
      collection do
        get "deduire_commune"
      end
    end
  end

  get "/retour-ent", to: "authentification_cas_ent#retour_cas"
  get "/from-ent", to: "authentification_cas_ent#appel_direct_ent"
  get "/choix-dossier", to: "authentification_cas_ent#choix_dossier"
  get "/debug-ent", to:  "authentification_cas_ent#debug_ent"


  post "/identification", to: "accueil#identification"

  get "/accueil", to: "accueil#accueil"
  post "/accueil", to: "accueil#post_accueil"
  get "/confirmation", to: "accueil#confirmation"

  get "/eleve", to: "accueil#eleve"
  post "/eleve", to: "accueil#post_eleve"

  get "/famille", to: "accueil#famille"
  post "/famille", to: "accueil#post_famille"

  get "/validation", to: "accueil#validation"
  post "/validation", to: "accueil#post_validation"

  get "/administration", to: "accueil#administration"
  post "/administration", to: "accueil#post_administration"

  post "/deconnexion", to: "accueil#deconnexion"

  post "/continuer_dossiersco", to: "accueil#continuer_dossiersco"
  post "/satisfaction", to: "accueil#satisfaction"
  post "/commentaire", to: "accueil#commentaire"

  get "/pieces_a_joindre", to: "accueil#pieces_a_joindre"
  post "/pieces_a_joindre", to: "accueil#post_pieces_a_joindre"

  get "/deconnexion", to: "accueil#deconnexion"

  get "/stats", to: "suivi#index"

  get "/agent", to: "inscriptions#agent"
  post "/agent", to: "inscriptions#post_agent"

  get "/agent/liste_des_eleves", to: "inscriptions#liste_des_eleves"

  get "/agent/eleve/:identifiant", to: "inscriptions#eleve"

  patch "/agent/eleve/:dossier_id", to: "inscriptions#update_eleve", as: "agent_update_eleve"

  patch "/agent/eleve/:dossier_eleve_id/modifier-mef-eleve", to: "inscriptions#modifier_mef_eleve", as: "modifier_mef_eleve"

  post "/agent/valider_inscription", to: "inscriptions#valider_inscription"

  post "/agent/eleve_sortant", to: "inscriptions#eleve_sortant"

  post "/agent/contacter_une_famille", to: "inscriptions#contacter_une_famille"

  post "/agent/relance_emails", to: "inscriptions#relance_emails"

  get "/agent/fusionne_modele/:modele_id/eleve/:identifiant", to: "inscriptions#fusionne_modele"

  post "/agent/valider_plusieurs_dossiers", to: "inscriptions#valider_plusieurs_dossiers"

  get "/agent/deconnexion", to: "inscriptions#deconnexion"

  get "/agent/tableau_de_bord", to: "inscriptions#tableau_de_bord"

  post "/agent/pieces_jointes_eleve/:identifiant", to: "inscriptions#post_pieces_jointes_eleve"

  get "/agent/export", to: "inscriptions#export"

  post "/agent/supprime_option", to: "inscriptions#supprime_option"

  post "/agent/supprime_piece_attendue", to: "inscriptions#supprime_piece_attendue"

  get "/agent/relance", to: "inscriptions#relance"
  post "/agent/relance_sms", to: "inscriptions#relance_sms"

  get "/redirection_erreur", to: "pages#redirection_erreur"
  get "/changelog", to: "pages#changelog"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" unless ENV["laisser_partir_les_emails"]

end
