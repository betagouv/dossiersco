# frozen_string_literal: true

class Famille

  def retrouve_un_email(dossier)
    premier_representant = dossier.resp_legal.find_by(priorite: 1)
    return premier_representant.email if premier_representant&.email.present?

    deuxieme_representant = dossier.resp_legal.where("priorite != 1").first
    return deuxieme_representant.email if deuxieme_representant&.email.present?

    raise ExceptionAucunEmailRetrouve, "Aucun email retrouvé"
  end

  def nettoyage_telephone(params)
    nettoie_resp_legal params if params["resp_legal_attributes"]

    if params["contact_urgence_attributes"]
      %w[tel_principal tel_secondaire].each do |tel|
        params["contact_urgence_attributes"][tel] = params["contact_urgence_attributes"][tel].delete(" ")
      end
    end

    params
  end

  def nettoie_resp_legal(params)
    %w[tel_personnel tel_portable tel_professionnel].each do |tel|
      if params["resp_legal_attributes"]["0"] && params["resp_legal_attributes"]["0"][tel]
        params["resp_legal_attributes"]["0"][tel] = params["resp_legal_attributes"]["0"][tel].delete(" ")
      end
      params["resp_legal_attributes"]["1"][tel] = params["resp_legal_attributes"]["1"][tel].delete(" ") if params["resp_legal_attributes"]["1"]
    end
  end

end
