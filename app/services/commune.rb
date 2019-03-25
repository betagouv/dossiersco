require 'csv'

class Commune

  def code_postal(code_postal)
    return [] unless code_postal
    villes = []
    CSV.foreach("app/services/laposte_hexasmal.csv", {:col_sep => ";"}) do |row|
      if row[2] == code_postal
        villes << row[1]
      end
    end
    villes.uniq
  end
end

