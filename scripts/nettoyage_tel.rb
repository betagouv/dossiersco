# frozen_string_literal: true

LONGUEUR_TEL = 10
def corrige_tel(type_tel, prefixe)
  RespLegal.where("length(#{type_tel}) = #{LONGUEUR_TEL - 1}").where("#{type_tel} LIKE ?", "#{prefixe}%").each do |r|
    puts "Corrige #{r[type_tel.to_sym]}"
    r.update_attribute(type_tel.to_sym, "0#{r[type_tel.to_sym]}")
  end
end

def supprime_tel(type_tel)
  params = {}
  params[type_tel.to_sym] = nil
  nb_tel_supprimes = RespLegal.where("length(#{type_tel}) < #{LONGUEUR_TEL} AND length(#{type_tel}) > 0").update_all(params)
  puts "#{nb_tel_supprimes} #{type_tel} supprimés"
end

puts "Nettoie les téléphones..."
%w[tel_personnel tel_portable tel_professionnel].each do |type_tel|
  %w[6 7].each { |prefixe| corrige_tel(type_tel, prefixe) }
  supprime_tel(type_tel)
end

