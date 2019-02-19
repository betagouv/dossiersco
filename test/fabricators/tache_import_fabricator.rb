# frozen_string_literal: true

Fabricator(:tache_import) do
  etablissement
  statut 'en attente'
end
