# frozen_string_literal: true

module Configuration
  class ExportsController < ApplicationController

    before_action :if_agent_is_admin

    def export_options
      ExportOptionsJob.perform_later(@agent_connecte)

      flash[:notice] = t(".export_des_options")
      redirect_to new_tache_import_path
    end

    def export_siecle
      @etablissement = @agent_connecte.etablissement
      respond_to do |format|
        format.xml
      end
    end

  end
end
