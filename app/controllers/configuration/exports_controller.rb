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

      xml_string = render_to_string layout: false
      file = Tempfile.new(['export_pour_siecle','.xml'])
      file.write(xml_string)
      file.close
      send_file file.path, :x_sendfile => true, :type => 'text/xml'
    end

  end
end
