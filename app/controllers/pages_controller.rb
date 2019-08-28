# frozen_string_literal: true

require "redcarpet"
require "redcarpet/render_strip"

class PagesController < ApplicationController

  def redirection_erreur
    if !eleve.nil?
      redirect_to accueil_path
    elsif !agent_connecte.nil?
      redirect_to agent_tableau_de_bord_path
    else
      redirect_to root_path
    end
  end

  def eleve
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
  end

  def changelog
    fichier = File.join(Rails.root, "CHANGELOG.md")
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, {})

    contenue = markdown.render(File.read(fichier)).to_s

    render html: contenue.html_safe, layout: "connexion"
  end

  def retour_siecle
    fichier = File.join(Rails.root, "doc/retour_base_eleve.md")
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, {})

    contenue = markdown.render(File.read(fichier)).to_s

    render html: contenue.html_safe, layout: "connexion"
  end

end
