class ImportMailer < ApplicationMailer

  def succes_import(etablissement_id, statistiques)
    @statistiques = statistiques
    @etablissement = Etablissement.find(etablissement_id)
    mail(subject: "Import de votre base élève dans DossierSCO",
         reply_to: 'contact@dossiersco.beta.gouv.fr',
         delivery_method_options: { api_key: ENV['MAILER_API_KEY'], secret_key: ENV['MAILER_SECRET_KEY'] },
         to: @etablissement.email) do |format|
      format.text
    end
  end
end
