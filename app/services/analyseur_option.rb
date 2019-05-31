# frozen_string_literal: true

class AnalyseurOption

  def initialize(dossier)
    @dossier = dossier
  end

  def option_maintenue
    options = []
    @dossier.options_origines.each do |id_option, _option|
      option_pedagogique = @dossier.options_pedagogiques.select { |o| o.id == id_option.to_i }.first
      options << option_pedagogique if option_pedagogique
    end
    options
  end

  def option_abandonnee
    options = []
    @dossier.options_origines.each do |id_option, _option|
      if @dossier.options_pedagogiques.select { |o| o.id == id_option.to_i }.empty?
        option_pedagogique = OptionPedagogique.find(id_option)
        options << option_pedagogique
      end
    end
    options
  end

  def option_demandee
    options = []
    @dossier.options_pedagogiques.each do |option|
      options << option unless @dossier.options_origines.key?(option.id.to_s)
    end
    options
  end

end
