class AddEmailReponseToEtablissements < ActiveRecord::Migration[5.2]
  def change
    add_column :etablissements, :email_reponse, :string
  end
end
