# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end


ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'dossier affelnet', 'dossiers affelnet'
  inflect.irregular 'dossier_affelnet', 'dossiers_affelnet'
  inflect.irregular 'DossierAffelnet', 'DossiersAffelnet'
  inflect.irregular 'OptionPedagogique', 'OptionsPedagogiques'
  inflect.irregular 'option_pedagogique', 'options_pedagogiques'
  inflect.irregular 'option pedagogique', 'options pedagogiques'
  inflect.irregular 'mef', 'mef'
  inflect.irregular 'piece_jointe', 'pieces_jointes'
  inflect.irregular 'piece jointe', 'pieces jointes'
  inflect.irregular 'dossier eleve', 'dossier eleves'
  inflect.irregular 'DossierEleve', 'DossierEleves'
  inflect.irregular 'dossier_eleve', 'dossier_eleves'
  inflect.irregular 'piece attendue', 'pieces attendues'
  inflect.irregular 'PieceAttendue', 'PiecesAttendues'
  inflect.irregular 'piece_attendue', 'pieces_attendues'
  inflect.irregular 'montee_pedagogique', 'montees_pedagogiques'
  inflect.irregular 'monteePedagogique', 'monteesPedagogiques'
  inflect.irregular 'montee pedagogique', 'montees pedagogiques'
end
