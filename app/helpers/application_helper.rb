# frozen_string_literal: true

module ApplicationHelper
  def construire(champs)
    champs.map do |champ|
      render partial: "partials/champ", locals: champ
    end.join
  end

  def super_admin?(identifiant)
    env_super_admin = ENV["SUPER_ADMIN"]
    env_super_admin ||= ""
    identifiant ||= ""
    env_super_admin.upcase.split(",").map(&:strip).include?(identifiant.upcase)
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
end
