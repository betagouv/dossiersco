class PiecesJointesController < ApplicationController
  before_action :retrouve_élève_connecté

  def create
    result = PieceJointe.create(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve))
    puts result.errors.inspect
  end

  def update
  end

  private
  def piece_jointe_params
    params.require(:piece_jointe).permit(:fichier, :piece_attendue_id)
  end
end

