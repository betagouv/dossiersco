class AddTelephoneToDossierEleve < ActiveRecord::Migration[5.2]
  def change
    add_column :resp_legals, :tel_personnel, :string
    add_column :resp_legals, :tel_portable, :string
    add_column :resp_legals, :tel_professionnel, :string

    RespLegal.all.each do |responsable|
      responsable.tel_personnel = responsable.tel_personnel
      responsable.tel_portable = responsable.tel_portable
      responsable.save
    end

    remove_column :resp_legals, :tel_principal
    remove_column :resp_legals, :tel_secondaire
  end
end
