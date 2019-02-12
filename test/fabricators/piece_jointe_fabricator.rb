# frozen_string_literal: true

Fabricator(:piece_jointe) do
  dossier_eleve
  piece_attendue
  etat PieceJointe::ETATS[:soumis]
end
