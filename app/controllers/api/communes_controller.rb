# frozen_string_literal: true

class Api::CommunesController < ApplicationController

  def deduire_commune
    commune = Commune.new
    communes = commune.code_postal(params[:code_postal])
    render json: communes
  end

end
