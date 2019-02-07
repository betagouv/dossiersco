module ApplicationHelper

  def construire champs
    champs.map do |champ|
      render partial: 'partials/champ', locals: champ
    end.join
  end

  def super_admin?(identifiant)
    env_super_admin = ENV['SUPER_ADMIN']
    env_super_admin ||= ""
    identifiant ||= ""
    env_super_admin.upcase.split(',').map(&:strip).include?(identifiant.upcase)
  end
end
