# frozen_string_literal: true

Fabricator(:tache_import) do
  etablissement
  statut TacheImport::STATUTS[:en_attente]
end

Fabricator(:tache_import_en_attente, from: :tache_import) do
  statut TacheImport::STATUTS[:en_attente]
end

Fabricator(:tache_import_en_traitement, from: :tache_import) do
  statut TacheImport::STATUTS[:en_traitement]
end
