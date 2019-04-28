class FichesInfirmeriesController < ApplicationController
  layout "agent"

  before_action :identification_agent

  def fiches_infirmeries
    respond_to do |format|
      format.zip {build_zip}
      format.html
    end
  end

  def build_zip
    etablissement = @agent_connecté.etablissement
    pdf = GenerePdf.new
    zip_data = pdf.generer_pdf_par_classes(etablissement, 'PdfFicheInfirmerie')
    send_data(zip_data, :type => 'application/zip', :filename => "fiches-infirmerie.zip")
  end

end

