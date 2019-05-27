# frozen_string_literal: true

class ConvocationJob < ActiveJob::Base

  def perform(etablissement, agent)
    pdf = GenerePdf.new
    fichier_a_telecharger = pdf.generer_pdf_par_classes(etablissement, "PdfConvocation")
  end

end
