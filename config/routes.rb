# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "accueil#index"

  resource :dossier_affelnet, only: [:create] do
    post :traiter
  end

  resource  :configuration, only: [:show]

  resources :etablissement, only: [] do
    member do
      get "fiches_infirmeries", to: "fiches_infirmeries#fiches_infirmeries"
      get "generation_fiches_infirmerie", to: "fiches_infirmeries#generation_fiches_infirmerie"
      get "convocations", to: "convocations#convocations"
      get "generation_convocations", to: "convocations#generation_convocations"
    end
  end

  namespace :configuration do
    resources :options_pedagogiques, except: [:show] do
      member do
        post "ajoute_option_au_mef"
        delete "enleve_option_au_mef"
      end
      collection do
        post "definie_abandonnabilite"
        get "liste"
      end
    end
    resources :mef

    resources :etablissements, expect: %i[destroy] do
      put "purge"
    end

    resources :agents do
      member do
        post "changer_etablissement"
      end
      get "activation"
    end
    resources :pieces_attendues, expect: [:show]
    resource :exports, only: :[] do
      collection do
        get "export-options", defaults: { format: "xlsx" }
        get "export-siecle", defaults: { format: "xml" }
      end
    end
    resources :regimes_sortie
  end

  resources :pieces_jointes, only: %i[create update] do
    member do
      put "valider"
      put "refuser"
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


  post "/identification", to: "accueil#identification"
  get "/accueil", to: "accueil#accueil"

  get "/eleve", to: "accueil#eleve"
  post "/eleve", to: "accueil#post_eleve"

  get "/famille", to: "accueil#famille"
  post "/famille", to: "accueil#post_famille"

  get "/validation", to: "accueil#validation"
  post "/validation", to: "accueil#post_validation"

  get "/administration", to: "accueil#administration"
  post "/administration", to: "accueil#post_administration"

  post "/deconnexion", to: "accueil#deconnexion"

  get "/confirmation", to: "accueil#confirmation"

  post "/satisfaction", to: "accueil#satisfaction"
  post "/commentaire", to: "accueil#commentaire"

  get "/pieces_a_joindre", to: "accueil#pieces_a_joindre"
  post "/pieces_a_joindre", to: "accueil#post_pieces_a_joindre"

  get "/deconnexion", to: "accueil#deconnexion"

  get "/stats", to: "accueil#stats"

  get "/agent", to: "inscriptions#agent"
  post "/agent", to: "inscriptions#post_agent"

  get "/agent/liste_des_eleves", to: "inscriptions#liste_des_eleves"

  get "/agent/eleve/:identifiant", to: "inscriptions#eleve"

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

  mount LetterOpenerWeb::Engine, at: "/letter_opener" unless ENV["laisser_partir_les_emails"]
end
