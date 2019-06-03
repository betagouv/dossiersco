# frozen_string_literal: true

class PresenterOptionsPedagogiques

  attr_reader :options

  def initialize(mef_destination)
    @options = []
    options = mef_destination&.options_pedagogiques
    options ||= []
    options.each do |option|
      @options << option if option.ouverte_inscription?(mef_destination)
    end
  end

end
