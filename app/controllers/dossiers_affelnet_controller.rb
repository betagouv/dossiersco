class DossiersAffelnetController < ApplicationController
  before_action :identification_agent
  layout 'layout_agent'

  def create
    tempfile = params[:fichier].tempfile
    @nom_fichier = params[:fichier].original_filename
    xls_document = Roo::Spreadsheet.open tempfile
    @nombre_de_lignes = xls_document.last_row - 1
    render :traitement_import
  end
end
