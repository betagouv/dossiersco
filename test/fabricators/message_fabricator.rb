# frozen_string_literal: true

Fabricator(:message) do
  dossier_eleve
  contenu "un message texte"
end
