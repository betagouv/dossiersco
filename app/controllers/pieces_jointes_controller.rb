class PiecesJointesController < ApplicationController
  before_action :retrouve_élève_connecté, only: [:create, :update]
  before_action :agent_connecté, only: [:valider, :refuser]
  before_action :retrouve_piece_jointe, only: [:update, :valider, :refuser]

  def create
    PieceJointe.create!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve))
    piece_jointe.soumet!
    redirect_to '/pieces_a_joindre'
  end

  def update
    piece_jointe = PieceJointe.find(params[:id])
    piece_jointe.update!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve))
    piece_jointe.soumet!
    redirect_to '/pieces_a_joindre'
  end

  def valider
    @piece_jointe.valide!
    redirect_to "/agent/eleve/#{params[:identifiant]}"
  end

  def refuser
    @piece_jointe.invalide!
    redirect_to "/agent/eleve/#{params[:identifiant]}"
  end

  private
  def piece_jointe_params
    params.require(:piece_jointe).permit(:fichier, :piece_attendue_id)
  end

  def retrouve_piece_jointe
    @piece_jointe = PieceJointe.find(params[:id])
  end
end

