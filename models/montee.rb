class Montee < ActiveRecord::Base
   has_many :demandabilite
   has_many :abandonnabilite
end
