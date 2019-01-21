class OptionPedagogique < ApplicationRecord
  has_and_belongs_to_many :mef
end
