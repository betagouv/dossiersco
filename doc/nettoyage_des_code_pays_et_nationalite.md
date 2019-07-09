# Nettoyage code pays

Sur le week-end du 6/7 juillet, avec le lundi 8, nettoyage des données de code pays pour les faire correspondres aux code pays SIECLE.


Pour un pays == un code, pas de note particulière.

Pour les cas particulier, note des id et d'autres informations.


Pour les `RESP_LEGAL`

Un changement majeur : un `resp_legal` sur la GLP (Guadeloupe) qui a été mélangé à la France.

2019-07-07T21:16:03.875404 #21]




`Eleve.pays_naiss`

Eleve 24142 
avant `pays_naiss` : "VIET NAM DU SUD"
après `pays_naiss` : "243" (VIETNAM)

Eleve 24665,
avant `pays_naiss` : "VIET NAM DU NORD"
après `pays_naiss` : "243" (VIETNAM)

Eleve 23195,
avant `pays_naiss` : "ALLEMAGNE (REPUBLIQUE DEMOCRATIQUE)"
après `pays_naiss` : "109" (ALLEMAGNE)

Eleves [39838, 24113, 30153]
avant `pays_naiss` : "ALLEMAGNE (REPUBLIQUE FEDERALE et DEFA)"
après `pays_naiss` : "109" (ALLEMAGNE)

Eleve 38851,
avant `pays_naiss` : "FRANCE/REUNION"
après `pays_naiss` : "100" (FRANCE)

Eleve 35235,
avant `pays_naiss` : "MARTINIQUE"
après `pays_naiss` : "100" (FRANCE)

Eleve 32160,
avant `pays_naiss` : "Mayotte "
après `pays_naiss` : "100" (FRANCE)

Eleve 43713,
avant `pays_naiss` : "POLYNESIE FRANCAISE"
après `pays_naiss` : "100" (FRANCE)

Eleve 38036,
avant `pays_naiss` : "Polynésie Française"
après `pays_naiss` : "100" (FRANCE)


```
irb(main):391:0> Eleve.all.map(&:pays_naiss).uniq.sort_by{|e| e.to_s }
D, [2019-07-07T22:43:41.246145 #22] DEBUG -- :   Eleve Load (34.3ms)  SELECT "eleves".* FROM "eleves"
=> [nil, "100", "101", "105", "109", "110", "111", "114", "116", "118", "122", "123", "125", "126", "127", "130", "131", "132", "134", "136", "137", "138", "139", "140", "148", "151", "155", "156", "201", "203", "204", "205", "206", "207", "208", "212", "213", "216", "217", "219", "220", "223", "226", "234", "235", "236", "239", "240", "243", "246", "247", "250", "252", "253", "255", "256", "257", "259", "261", "301", "303", "312", "314", "315", "316", "318", "319", "321", "322", "323", "324", "326", "327", "328", "330", "331", "333", "335", "336", "338", "340", "341", "342", "343", "344", "345", "350", "351", "352", "390", "392", "395", "396", "397", "401", "404", "405", "406", "407", "410", "416", "417", "418", "419", "420", "421", "422", "424", "501", "502", "508", "KOSOVO", "PAYS-BAS", "REPUBLIQUE DOMINICAINE", "SERBIE"]
irb(main):392:0>
irb(main):393:0>
irb(main):394:0> Eleve.where(pays_naiss: nil).count                                 
D, [2019-07-07T22:43:54.729620 #22] DEBUG -- :    (3.8ms)  SELECT COUNT(*) FROM "eleves" WHERE "eleves"."pays_naiss" IS NULL
=> 13
irb(main):395:0>
...


Eleve 24142,
avant `nationalite`: "VIET NAM DU SUD"
après `nationalite` : "243" (VIETNAM)

Eleve 24665,
avant `nationalite`: "VIET NAM DU NORD"
après `nationalite` : "243" (VIETNAM)

Eleve 23195,
avant `nationalite` : "ALLEMAGNE (REPUBLIQUE DEMOCRATIQUE)"
après `nationalite` : "109" (ALLEMANDE)

Eleve [39838, 24113, 30153]
avant `nationalite` : "ALLEMAGNE (REPUBLIQUE FEDERALE et DEFA)"
après `nationalite` : "109" (ALLEMANDE)


Eleve 35385,
avant `pays_naiss` : "REPUBLIQUE DOMINICAINE"
après `pays_naiss` : "990" (autre pays)

Eleve [39785, 39894, 39917, 39977, 39978, 14713, 36201, 28841, 42724]
avant `pays_naiss` : "KOSOVO"
après `pays_naiss` : "157" (KOSOVO)

Eleve 35385,
avant `nationalite` : "REPUBLIQUE DOMINICAINE"
après `nationalite` : "990" (autre nationalite)

Eleve 24243,
avant `nationalite` : "FRANCE et JAPON"
après `nationalite` : "990" (autre nationalite)

Eleve 24009,
avant `nationalite` : "FRANCE-SUEDE"
après `nationalite` : "990" (autre nationalite)

Eleve [24465, 24023]
avant `nationalite` : "JAPON - France"
après `nationalite` : "990" (autre nationalite)

Eleve 24464,
avant `nationalite` : "JAPON et FRANCE"
après `nationalite` : "990" (autre nationalite)


