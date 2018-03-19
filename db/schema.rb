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

ActiveRecord::Schema.define(version: 20180319135356) do

  create_table "dossier_eleves", force: :cascade do |t|
    t.integer "eleve_id"
    t.string "demarche"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

end
