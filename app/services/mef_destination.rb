# frozen_string_literal: true

class MefDestination

  def initialize(etablissement)
    @etablissement = etablissement
  end

  def mef_destination(mef_origine)
    mefs_destination = DossierEleve.select(:mef_destination_id).where(etablissement: @etablissement, mef_origine: mef_origine).group(:mef_destination_id).map(&:mef_destination)
    return mefs_destination.first if mefs_destination.length == 1
  end

end
