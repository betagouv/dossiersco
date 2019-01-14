module ApplicationHelper
  def construire champs
    champs.map do |champ|
      render partial: 'partials/champ', locals: champ
    end.join
  end
end
