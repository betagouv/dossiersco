# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_28_165248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abandonnabilites", force: :cascade do |t|
    t.integer "montee_id"
    t.integer "option_id"
  end

  create_table "abandons", force: :cascade do |t|
    t.integer "eleve_id"
    t.integer "option_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.string "identifiant"
    t.string "prenom"
    t.string "nom"
    t.string "password"
    t.integer "etablissement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin"
    t.string "password_digest"
  end

  create_table "contact_urgences", force: :cascade do |t|
    t.integer "dossier_eleve_id"
    t.string "lien_avec_eleve"
    t.string "prenom"
    t.string "nom"
    t.string "tel_principal"
    t.string "tel_secondaire"
    t.datetime "updated_at"
  end

  create_table "demandabilites", force: :cascade do |t|
    t.integer "montee_id"
    t.integer "option_id"
  end

  create_table "demandes", force: :cascade do |t|
    t.integer "eleve_id"
    t.integer "option_id"
  end

  create_table "dossier_eleves", force: :cascade do |t|
    t.bigint "eleve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "etablissement_id"
    t.string "etat", default: "pas connecté"
    t.integer "satisfaction", default: 0
    t.boolean "demi_pensionnaire", default: false
    t.boolean "autorise_sortie", default: false
    t.boolean "renseignements_medicaux", default: false
    t.boolean "autorise_photo_de_classe", default: true
    t.boolean "check_paiement_cantine", default: false
    t.string "etape_la_plus_avancee", default: "accueil"
    t.text "commentaire"
    t.boolean "signature", default: false
    t.datetime "date_signature"
    t.string "derniere_etape"
    t.bigint "mef_origine_id"
    t.bigint "mef_destination_id"
    t.index ["eleve_id"], name: "index_dossier_eleves_on_eleve_id"
    t.index ["mef_destination_id"], name: "index_dossier_eleves_on_mef_destination_id"
    t.index ["mef_origine_id"], name: "index_dossier_eleves_on_mef_origine_id"
  end

  create_table "dossiers_affelnet", force: :cascade do |t|
    t.bigint "etablissement_id"
    t.string "nom"
    t.string "prenom"
    t.date "date_naissance"
    t.string "etablissement_origine"
    t.string "etablissement_accueil"
    t.integer "rang"
    t.string "dérogation"
    t.string "formation_accueil"
    t.string "decision_de_passage"
    t.index ["etablissement_id"], name: "index_dossiers_affelnet_on_etablissement_id"
  end

  create_table "eleves", force: :cascade do |t|
    t.string "identifiant"
    t.string "prenom"
    t.string "nom"
    t.string "sexe"
    t.string "ville_naiss"
    t.string "nationalite"
    t.string "classe_ant"
    t.string "ets_ant"
    t.string "date_naiss"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "pays_naiss"
    t.string "niveau_classe_ant"
    t.string "prenom_2"
    t.string "prenom_3"
    t.integer "montee_id"
  end

  create_table "eleves_options", force: :cascade do |t|
    t.integer "eleve_id"
    t.integer "option_id"
  end

  create_table "etablissements", force: :cascade do |t|
    t.string "nom"
    t.string "date_limite"
    t.string "adresse"
    t.string "ville"
    t.string "code_postal"
    t.string "message_permanence"
    t.datetime "updated_at"
    t.text "message_infirmerie"
    t.string "email"
    t.boolean "gere_demi_pension", default: false
    t.string "signataire", default: ""
  end

  create_table "mef", force: :cascade do |t|
    t.string "libelle"
    t.string "code"
    t.bigint "etablissement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etablissement_id"], name: "index_mef_on_etablissement_id"
  end

  create_table "mef_options_pedagogiques", force: :cascade do |t|
    t.bigint "mef_id"
    t.bigint "option_pedagogique_id"
    t.index ["mef_id"], name: "index_mef_options_pedagogiques_on_mef_id"
    t.index ["option_pedagogique_id"], name: "index_mef_options_pedagogiques_on_option_pedagogique_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "dossier_eleve_id"
    t.string "categorie"
    t.string "contenu"
    t.string "etat"
    t.string "resultat"
    t.datetime "created_at"
    t.string "destinataire", default: "rl1"
  end

  create_table "modeles", force: :cascade do |t|
    t.integer "etablissement_id"
    t.string "nom"
    t.string "contenu"
  end

  create_table "montees", force: :cascade do |t|
    t.integer "niveau_ant"
    t.integer "etablissement_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "nom"
    t.string "groupe"
    t.string "modalite"
    t.string "info"
  end

  create_table "options_pedagogiques", force: :cascade do |t|
    t.string "nom"
    t.string "groupe"
    t.boolean "obligatoire", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "etablissement_id"
    t.index ["etablissement_id"], name: "index_options_pedagogiques_on_etablissement_id"
  end

  create_table "piece_attendues", force: :cascade do |t|
    t.string "nom"
    t.string "code"
    t.string "explication"
    t.integer "etablissement_id"
    t.boolean "obligatoire", default: false
  end

  create_table "pieces_jointes", force: :cascade do |t|
    t.string "clef"
    t.integer "dossier_eleve_id"
    t.integer "piece_attendue_id"
    t.string "etat"
  end

  create_table "resp_legals", force: :cascade do |t|
    t.integer "dossier_eleve_id"
    t.string "lien_de_parente"
    t.string "prenom"
    t.string "nom"
    t.string "adresse"
    t.string "code_postal"
    t.string "ville"
    t.string "tel_principal"
    t.string "tel_secondaire"
    t.string "email"
    t.string "profession"
    t.integer "enfants_a_charge"
    t.boolean "communique_info_parents_eleves"
    t.integer "priorite"
    t.datetime "updated_at"
    t.string "adresse_ant"
    t.string "ville_ant"
    t.string "code_postal_ant"
  end

  create_table "tache_imports", force: :cascade do |t|
    t.string "statut"
    t.string "url"
    t.integer "etablissement_id"
    t.datetime "created_at"
    t.string "nom_a_importer"
    t.string "prenom_a_importer"
    t.string "message"
    t.datetime "updated_at"
  end

  create_table "traces", force: :cascade do |t|
    t.string "identifiant"
    t.string "categorie"
    t.string "page_demandee"
    t.string "adresse_ip"
    t.datetime "created_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dossier_eleves", "eleves", column: "eleve_id"
  add_foreign_key "dossier_eleves", "mef", column: "mef_destination_id"
  add_foreign_key "dossier_eleves", "mef", column: "mef_origine_id"
  add_foreign_key "dossiers_affelnet", "etablissements"
  add_foreign_key "options_pedagogiques", "etablissements"
end
