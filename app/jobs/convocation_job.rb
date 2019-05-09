# frozen_string_literal: true

class ConvocationJob < ActiveJob::Base

  def perform(etablissement, agent)
    pdf = GenerePdf.new
    zip_data = pdf.generer_pdf_par_classes(etablissement, "PdfConvocation")

    mailer = AgentMailer.convocation(agent, zip_data)
    mailer.deliver_now
  end

end
