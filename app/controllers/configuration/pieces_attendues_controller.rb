# frozen_string_literal: true

module Configuration
  class PiecesAttenduesController < ApplicationController

    layout "configuration"

    before_action :identification_agent
    before_action :set_piece_attendue, only: %i[edit update destroy]

    def index
      @pieces_attendues = PieceAttendue.where(etablissement: agent_connecté.etablissement)
    end

    def new
      @piece_attendue = PieceAttendue.new
    end

    def edit; end

    def create
      @piece_attendue = PieceAttendue.new(piece_attendue_params)
      @piece_attendue.etablissement = agent_connecté.etablissement

      if @piece_attendue.save
        redirect_to configuration_pieces_attendues_path, notice: t(".piece_cree")
      else
        render :new
      end
    end

    def update
      if @piece_attendue.update(piece_attendue_params)
        redirect_to configuration_pieces_attendues_path, notice: t(".piece_mise_a_jour")
      else
        render :edit
      end
    end

    def destroy
      @piece_attendue.destroy
      redirect_to configuration_pieces_attendues_path, notice: t(".piece_mise_a_jour")
    end

    private

    def set_piece_attendue
      @piece_attendue = PieceAttendue.find(params[:id])
    end

    def piece_attendue_params
      params.require(:piece_attendue).permit(:nom, :code, :etablissement_id, :explication, :obligatoire)
    end

  end
end
