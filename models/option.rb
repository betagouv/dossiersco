class Option < ActiveRecord::Base
  has_and_belongs_to_many :eleve
  def nom_et_info
    self.nom + (self.info.present? ? " #{self.info}" : "")
  end
end

class Demande < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :option
end

class Demandabilite < ActiveRecord::Base
  belongs_to :montee
  belongs_to :option
end

class Abandon < ActiveRecord::Base
  belongs_to :eleve
  belongs_to :option
end

class Abandonnabilite < ActiveRecord::Base
  belongs_to :montee
  belongs_to :option
end
