# frozen_string_literal: true

class PresenterOptionsPedagogiques

  attr_reader :options

  def initialize(mef_destination)
    @options = []

    if mef_destination.present?
      mef_destination.options_pedagogiques.each do |option|
        @options << option if option.ouverte_inscription?(mef_destination)
      end
    end
  end

end
