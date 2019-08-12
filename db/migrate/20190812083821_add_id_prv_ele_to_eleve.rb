class AddIdPrvEleToEleve < ActiveRecord::Migration[5.2]
  def change
    add_column :eleves, :id_prv_ele, :string
  end
end
