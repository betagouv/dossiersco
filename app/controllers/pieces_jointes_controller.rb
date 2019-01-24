class PiecesJointesController < ApplicationController
  before_action :retrouve_élève_connecté

  def create
    PieceJointe.create!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve, etat: 'soumis'))
    redirect_to '/pieces_a_joindre'
  end

  def update
    piece_jointe = PieceJointe.find(params[:id])
    piece_jointe.update!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve, etat: 'soumis'))
    redirect_to '/pieces_a_joindre'
  end

  private
  def piece_jointe_params
    params.require(:piece_jointe).permit(:fichier, :piece_attendue_id)
  end
end

