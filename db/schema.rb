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

ActiveRecord::Schema.define(version: 20180411121606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "identifiant"
    t.string "prenom"
    t.string "nom"
    t.string "password"
    t.integer "etablissement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_urgences", force: :cascade do |t|
    t.integer "dossier_eleve_id"
    t.string "lien_avec_eleve"
    t.string "prenom"
    t.string "nom"
    t.string "adresse"
    t.string "code_postal"
    t.string "ville"
    t.string "tel_principal"
    t.string "tel_secondaire"
  end

  create_table "dossier_eleves", force: :cascade do |t|
    t.bigint "eleve_id"
    t.string "demarche"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "etablissement_id"
    t.string "photo_identite"
    t.string "assurance_scolaire"
    t.string "jugement_garde_enfant"
    t.string "etat", default: "pas connecté"
    t.string "etat_photo_identite"
    t.string "etat_assurance_scolaire"
    t.string "etat_jugement_garde_enfant"
    t.integer "satisfaction", default: 0
    t.index ["eleve_id"], name: "index_dossier_eleves_on_eleve_id"
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
    t.string "lv2"
    t.string "date_naiss"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "pays_naiss"
    t.string "niveau_classe_ant"
  end

  create_table "etablissements", force: :cascade do |t|
    t.string "nom"
    t.string "date_limite"
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
    t.string "situation_emploi"
    t.string "profession"
    t.integer "enfants_a_charge"
    t.integer "enfants_a_charge_secondaire"
    t.boolean "communique_info_parents_eleves"
    t.integer "priorite"
  end

  add_foreign_key "dossier_eleves", "eleves", column: "eleve_id"
end
