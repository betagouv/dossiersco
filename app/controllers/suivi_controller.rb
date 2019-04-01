class SuiviController < ApplicationController
  layout 'connexion'

  def index
    @suivi = Suivi.new

    Etablissement.all.each do |etablissement|
      if etablissement.agent.count == 1 &&
          etablissement.agent.first.jeton.present?
        @suivi.pas_encore_connecte += 1
      end

      if etablissement.dossier_eleve.count > 0
        @suivi.eleves_importe += 1
      end

      if etablissement.pieces_attendues.count > 0
        @suivi.piece_attendue_configure += 1
      end

      if etablissement.dossier_eleve.map(&:etat).include?('connecté')
        @suivi.familles_connectes += 1
      end
    end


  end

end

class Suivi
  attr_accessor :pas_encore_connecte, :eleves_importe, :piece_attendue_configure, :familles_connectes

  def initialize
    @pas_encore_connecte = 0
    @eleves_importe = 0
    @piece_attendue_configure = 0
    @familles_connectes = 0
  end
end
