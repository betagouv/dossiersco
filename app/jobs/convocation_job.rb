# frozen_string_literal: true

class ConvocationJob < ActiveJob::Base

  def perform(etablissement, agent)
    pdf = GenerePdf.new
    fichier_a_telecharger = pdf.generer_pdf_par_classes(etablissement, "PdfConvocation")

    mailer = AgentMailer.convocation(agent, fichier_a_telecharger)
    mailer.deliver_now
  end

end
