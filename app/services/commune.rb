# frozen_string_literal: true

require 'csv'

class Commune
  def code_postal(code_postal)
    return [] unless code_postal

    villes = []
    CSV.foreach('app/services/laposte_hexasmal.csv', col_sep: ';') do |row|
      villes << row[1] if row[2] == code_postal
    end
    villes.uniq
  end
end
