# frozen_string_literal: true

class PiecesJointesController < ApplicationController

  before_action :retrouve_eleve_connecte, only: %i[create update]
  before_action :agent_connecte, only: %i[valider refuser]
  before_action :retrouve_piece_jointe, only: %i[update valider refuser annuler_decision, show]

  def create
    PieceJointe.create!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve, etat: PieceJointe::ETATS[:soumis]))
    redirect_to "/pieces_a_joindre"
  end

  def update
    piece_jointe = PieceJointe.find(params[:id])
    piece_jointe.update!(piece_jointe_params.merge(dossier_eleve: @eleve.dossier_eleve))
    piece_jointe.soumet!
    redirect_to "/pieces_a_joindre"
  end

  def show
    puts @piece_jointe.inspect
    if @piece_jointe.fichiers.length == 1
      if Rails.env.development?
        redirect_to @piece_jointe.fichiers.first.url
      else
        render :text => proc { |response, output|
          AWS::S3::S3Object.stream(path, bucket) do |segment|
            output.write segment
            output.flush # not sure if this is needed
          end
        }
      end
    else
      render text: "trop de fichiers à montrer"
    end
  end

  def valider
    @piece_jointe.valide!
    redirect_to "/agent/eleve/#{params[:identifiant]}#pieces-jointes"
  end

  def refuser
    @piece_jointe.invalide!
    redirect_to "/agent/eleve/#{params[:identifiant]}#pieces-jointes"
  end

  def annuler_decision
    @piece_jointe.soumet!
    redirect_to "/agent/eleve/#{params[:identifiant]}#pieces-jointes"
  end

  private

  def piece_jointe_params
    params.require(:piece_jointe).permit({ fichiers: [] }, :piece_attendue_id)
  end

  def retrouve_piece_jointe
    @piece_jointe = PieceJointe.find(params[:id])
  end

end
