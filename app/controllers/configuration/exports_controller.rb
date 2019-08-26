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

      base_dossiers = @etablissement.dossier_eleve.exportables
      @dossiers = if params[:liste_ine].present?
                    base_dossiers.joins(:eleve).where("eleves.identifiant in (?)", params[:liste_ine].split(","))
                  else
                    base_dossiers
                  end
      year = Time.now.strftime("%Y")
      next_year = Time.now.strftime("%y").to_i + 1
      timestamp = Time.now.strftime("%m%d%I%M%S")
      nom_fichier = "#{@agent_connecte.etablissement.uai}PRIVE#{year}#{next_year}#{timestamp}"

      file = construit_xml(nom_fichier)

      nom_zip = "#{nom_fichier}.zip"
      temp_file = Tempfile.new(nom_zip)

      if params[:xml_only]
        send_file file.path, x_sendfile: true, type: "text/xml"
      else
        Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
          zipfile.add("#{nom_fichier}.xml", file)
        end
        zip_data = File.read(temp_file.path)
        send_data(zip_data, type: "application/zip", filename: nom_zip)
      end
    end

    def construit_xml(nom_fichier)
      xml_string = render_to_string layout: false
      file = Tempfile.new("#{nom_fichier}.xml")
      file.write(xml_string)
      file.close

      file
    end

    def export_pieces_jointes
      ExportPiecesJointesJob.perform_later(@agent_connecte, params[:mef])

      flash[:notice] = t(".export_des_pieces_jointes")
      redirect_to new_tache_import_path
    end

  end
end
