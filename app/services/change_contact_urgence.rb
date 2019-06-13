# frozen_string_literal: true

class ChangeContactUrgence

  def initialize(dossier)
    @dossier = dossier
  end

  def applique(params)
    contact_urgence = ContactUrgence.find_by(dossier_eleve_id: @dossier.id) ||
                      ContactUrgence.new(dossier_eleve_id: @dossier.id)

    %w[lien_avec_eleve prenom nom tel_principal tel_secondaire].each do |i|
      contact_urgence[i] = params["#{i}_urg"] if params.key?("#{i}_urg")
    end

    contact_urgence.save!
  end

end
