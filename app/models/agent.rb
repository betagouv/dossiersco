class Agent < ActiveRecord::Base
  belongs_to :etablissement
  has_secure_password
end
