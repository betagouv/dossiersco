# frozen_string_literal: true

module Configuration
  class ExportsController < ApplicationController

    before_action :if_agent_is_admin

    def export_options
      ExportElevesXlsxJob.perform_later(@agent_connecte)

      flash[:notice] = t(".export_des_options")
      redirect_to new_tache_import_path
    end

    def export_siecle
      @etablissement = @agent_connecte.etablissement

      @dossiers = if params[:limite]
                    @etablissement.dossier_eleve.joins(:eleve).where("eleves.identifiant in (?)", params[:liste_ine].split(","))
                  else
                    @etablissement.dossier_eleve
                  end

      xml_string = render_to_string layout: false
      nom_fichier = "#{@agent_connecte.etablissement.uai}PRIVE#{Time.now.strftime('%Y')}#{Time.now.strftime('%y').to_i + 1}#{Time.now.strftime('%m%d%I%M%S')}"
      file = Tempfile.new("#{nom_fichier}.xml")
      file.write(xml_string)
      file.close

      nom_zip = "#{nom_fichier}.zip"
      temp_file = Tempfile.new(nom_zip)

      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        zipfile.add("#{nom_fichier}.xml", file)
      end
      zip_data = File.read(temp_file.path)
      send_data(zip_data, :type => 'application/zip', filename: nom_zip)

    end

    def export_pieces_jointes
      ExportPiecesJointesJob.perform_later(@agent_connecte, params[:mef])

      flash[:notice] = t(".export_des_pieces_jointes")
      redirect_to new_tache_import_path
    end

  end
end
