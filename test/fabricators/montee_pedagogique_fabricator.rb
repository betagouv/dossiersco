# frozen_string_literal: true

Fabricator(:montee_pedagogique) do
  mef_origine {Fabricate(:mef)}
  mef_destination {Fabricate(:mef)}
  option_pedagogique
end
