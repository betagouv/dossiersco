class CreateModeles < ActiveRecord::Migration[5.2]
  def change
    create_table :modeles do |t|
      t.integer   :etablissement_id
      t.string    :nom
      t.string    :contenu
    end
  end
end
