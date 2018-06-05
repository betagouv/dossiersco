class CreateMontee < ActiveRecord::Migration[5.1]
  def change
    create_table :montees do |t|
      t.integer :niveau_ant
      t.integer :etablissement_id
    end

    create_table :demandabilites do |t|
      t.integer :montee_id
      t.integer :option_id
    end

    create_table :abandonnabilites do |t|
      t.integer :montee_id
      t.integer :option_id
    end

    add_column :eleves, :montee_id, :integer
    add_column :options, :modalite, :string

    remove_column :options, :obligatoire
    remove_column :options, :niveau_debut
    remove_column :options, :etablissement_id

    Eleve.reset_column_information
    Montee.reset_column_information
    Option.reset_column_information

    latin = Option.create(nom: 'Latin',
              modalite: 'facultative',
              groupe: "Langues et culture de l'antiquité")
    latin_obligatoire = Option.create(nom: 'Latin',
              modalite: 'obligatoire',
              groupe: "Langues et culture de l'antiquité")
    allemand = Option.create(nom: 'Allemand',
              modalite: 'obligatoire',
              groupe: "Langue vivante 2")
    espagnol = Option.create(nom: 'Espagnol',
              modalite: 'obligatoire',
              groupe: "Langue vivante 2")
    grec = Option.create(nom: 'Grec',
              modalite: 'facultative',
              groupe: "Langues et culture de l'antiquité")

    etablissement = Etablissement.find_by(id: 228) # tillion
    if etablissement.present?
      mefs = ["6EME SEGPA",
          "6EME",
          "5EME SEGPA",
          "5EME HORAIRES AMENAGES MUSIQUE",
          "5EME",
          "4EME SEGPA",
          "4EME HORAIRES AMENAGES MUSIQUE",
          "4EME"]
      mefs.each do |mef|
        montee = Montee.create(niveau_ant: mef, etablissement_id: etablissement.id)
        case mef
          when /SEGPA/
            # Rien
          when /5EME/
            # Rien
          when "6EME" # Non bilangue
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: allemand.id)
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: espagnol.id)
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: latin.id)
          when /4EME/
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: grec.id)
            montee.abandonnabilite << Abandonnabilite.create(montee_id: montee.id, option_id: latin.id)
          else
        end
        montee.save
        dossiers = DossierEleve.joins(:eleve).where(eleves: {niveau_classe_ant: mef}, etablissement_id: etablissement)
        eleves = dossiers.collect(&:eleve)
        eleves.each do |eleve|
          eleve.montee = montee
          eleve.save
        end
      end
    end

    etablissement = Etablissement.find_by(id: 227) # malraux
    if etablissement.present?
      mefs = ["6EME UPE2A (EX CL. ACCUEIL)",
          "6EME BILANGUE DE CONTINUITE",
          "6EME",
          "5EME UPE2A (EX CL. ACCUEIL)",
          "5EME",
          "4EME UPE2A (EX CL. ACCUEIL)",
          "4EME"]
      mefs.each do |mef|
        montee = Montee.create(niveau_ant: mef, etablissement_id: etablissement.id)
        case mef
          when /UPE2A/ # 6è, 5è ou 4è
            # Rien
          when /5EME/
            # Rien
          when /BILANGUE/
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: latin.id)
          when "6EME" # Non bilangue
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: allemand.id)
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: espagnol.id)
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: latin.id)
          when "4EME"
            montee.demandabilite << Demandabilite.create(montee_id: montee.id, option_id: grec.id)
            montee.abandonnabilite << Abandonnabilite.create(montee_id: montee.id, option_id: latin.id)
        end
        montee.save
        dossiers = DossierEleve.joins(:eleve).where(eleves: {niveau_classe_ant: mef}, etablissement_id: etablissement)
        eleves = dossiers.collect(&:eleve)
        eleves.each do |eleve|
          eleve.montee = montee
          eleve.save
        end
      end
    end

  end
end
