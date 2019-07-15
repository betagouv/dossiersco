class AddCodeMatiere6ToOptionsPedagogique < ActiveRecord::Migration[5.2]
  def change
    add_column :options_pedagogiques, :code_matiere_6, :string
  end
end
