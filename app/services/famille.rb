# frozen_string_literal: true

class Famille

  def retrouve_un_email(dossier)
    premier_representant = dossier.resp_legal.find_by(priorite: 1)
    return premier_representant.email if premier_representant.email.present?

    deuxieme_representant = dossier.resp_legal.where("priorite != 1").first
    return deuxieme_representant.email if deuxieme_representant.email.present?

    raise ExceptionAucunEmailRetrouve, "Aucun email retrouvé"
  end

end
