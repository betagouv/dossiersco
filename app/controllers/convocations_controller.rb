# frozen_string_literal: true

class ConvocationsController < ApplicationController

  layout "agent"

  before_action :identification_agent

  def convocations
    etablissement = @agent_connecte.etablissement

    respond_to do |format|
      format.zip do
        pdf = GenerePdf.new
        zip_data = pdf.generer_pdf_par_classes(etablissement, "PdfConvocation")
        send_data(zip_data, type: "application/zip", filename: "convocations.zip")
      end
      format.html do
        @eleves_non_inscrits = DossierEleve.pour(etablissement).a_convoquer
        @eleves_non_inscrits = @eleves_non_inscrits.paginate(page: params[:page], per_page: 10)
      end
    end
  end

end
