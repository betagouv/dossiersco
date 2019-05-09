# frozen_string_literal: true

class FicheInfirmerieJob < ActiveJob::Base

  def perform(etablissement, agent)
    pdf = GenerePdf.new
    zip_data = pdf.generer_pdf_par_classes(etablissement, "PdfFicheInfirmerie")

    mailer = AgentMailer.fiche_infirmerie(agent, zip_data)
    mailer.deliver_now
  end

end
