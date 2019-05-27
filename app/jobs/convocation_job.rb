# frozen_string_literal: true

class ConvocationJob < ActiveJob::Base

  def perform(etablissement, _agent)
    pdf = GenerePdf.new
    pdf.generer_pdf_par_classes(etablissement, "PdfConvocation")
  end

end
