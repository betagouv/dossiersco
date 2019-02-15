class PiecesAttenduesController < ApplicationController
  before_action :identification_agent
  layout 'configuration'

  def index
    etablissement = agent_connecté.etablissement
    @pieces_attendues = etablissement.pieces_attendues
  end

  def create
    etablissement = agent_connecté.etablissement

    code_piece = piece_attendue_params[:nom].gsub(/[^a-zA-Z0-9]/, '_').upcase.downcase

    piece_attendue = PieceAttendue.find_by(code: code_piece, etablissement: etablissement.id)

    if !piece_attendue_params[:nom].present?
      message = "Une pièce doit comporter un nom"
      render :pieces_attendues, locals: {piece_attendues: etablissement.pieces_attendues, message: message}
    elsif piece_attendue.present? && (piece_attendue.nom == code_piece)
      message = "#{params[:nom]} existe déjà"
      render :pieces_attendues, locals: {piece_attendues: etablissement.pieces_attendues, message: message}
    else
      piece_attendue = PieceAttendue.create!(piece_attendue_params.merge(etablissement_id: etablissement.id, code: code_piece))
      redirect_to pieces_attendues_path
    end
  end

  private
  def piece_attendue_params
    params.require(:piece_attendue).permit(:nom, :explication, :obligatoire)
  end
end
