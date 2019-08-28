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

    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end

  def classe_pour_menu(etape, dossier, entrees_de_menu)
    index_etape = entrees_de_menu.index(etape)
    index_etape ||= 0
    index_dossier = entrees_de_menu.index(dossier.etape_la_plus_avancee)
    index_dossier ||= 0
    if index_dossier > index_etape
      "step step-enabled current done"
    elsif index_dossier == index_etape
      "step step-enabled current"
    else
      "step step-disabled"
    end
  end

  def lien_menu(etape, dossier, entrees_de_menu)
    index_etape = entrees_de_menu.index(etape)
    index_etape ||= 0
    index_dossier = entrees_de_menu.index(dossier.etape_la_plus_avancee)
    index_dossier ||= 0
    if index_dossier >= index_etape
      "/#{etape}"
    else
      "#"
    end
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

  def alternative(valeur)
    valeur.present? ? valeur : "Inconnu"
  end

  def nb_enfants_a_charge(resp_legal)
    resp_legal.enfants_a_charge&.positive? ? resp_legal.enfants_a_charge : 1
  end
end
