# frozen_string_literal: true

module ApplicationHelper
  def super_admin?(agent)
    return false unless agent

    env_super_admin = ENV["SUPER_ADMIN"]
    env_super_admin ||= ""
    env_super_admin.upcase.split(",").map(&:strip).include?(agent.email.upcase)
  end

  def affiche_etablissement(etablissement)
    "#{etablissement.nom} - #{etablissement.uai}"
  end

  def markdown(text)
    return "" if text.nil?

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end

  def options
    {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }
  end

  def extensions
    {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true
    }
  end

  def classe_pour_menu(etape, dossier, entrees_de_menu)
    if etape_courante_precede_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
      "step step-enabled current done"
    elsif etape_courante_equivalente_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
      "step step-enabled current"
    else
      "step step-disabled"
    end
  end

  def etape_courante_precede_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
    retrouve_index(entrees_de_menu, dossier.etape_la_plus_avancee) > retrouve_index(entrees_de_menu, etape)
  end

  def etape_courante_equivalente_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
    retrouve_index(entrees_de_menu, dossier.etape_la_plus_avancee) == retrouve_index(entrees_de_menu, etape)
  end

  def lien_menu(etape, dossier, entrees_de_menu)
    if etape_courante_equivalente_ou_precedente_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
      "/#{etape}"
    else
      "#"
    end
  end

  def etape_courante_equivalente_ou_precedente_etape_la_plus_avancee?(etape, dossier, entrees_de_menu)
    retrouve_index(entrees_de_menu, dossier.etape_la_plus_avancee) >= retrouve_index(entrees_de_menu, etape)
  end

  def retrouve_index(entrees_de_menu, etape)
    entrees_de_menu.index(etape) || 0
  end

  def abandonnable?(dossier, option)
    option.abandonnable?(dossier.mef_destination)
  end

  def ouverte?(dossier, option)
    option.ouverte_inscription?(dossier.mef_destination)
  end

  def selectionnee?(dossier, option)
    dossier.options_pedagogiques.include?(option)
  end

  def pratiquee?(dossier, option)
    dossier.options_origines[option.id.to_s].present?
  end

  def somme_suivi(suivi)
    suivi.pas_encore_connecte.count +
      suivi.eleves_importe.count +
      suivi.familles_connectes.count
  end

  def nom_pays(code_pays)
    liste_pays[code_pays.to_i]
  end

  def liste_pays
    YAML.safe_load(File.read(File.join(Rails.root, "/app/jobs/code_pays.yml")))
  end
end
