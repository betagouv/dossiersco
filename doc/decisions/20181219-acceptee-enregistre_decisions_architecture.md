# Utiliser les Enregistrement de Décision d'Architecture (ADR en anglais)

## Contexte

Les équipes se suivent et ne se ressemble pas forcement. L'oralité ne suffit
pas pour transmettre des informations, des décisions prises, un historique.

DossierSCO etant accessible en licence libre, c'est important de pouvoir être
transparant, et de communiquer, y compris sur nos décisions d'architecture.

## Décision

Documenter simplement, et prêt du code, nos décisions d'architecture en
utilisant la forme simple de fichier dans le repo git. Voir l'article source de
notre décision :
http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions.

Nous utiliserons (pour le moment) un simple fichier dans un répertoire
particulier `doc/architecture` dans le nom suivra la convention
`YYYYMMDD-titre.md` et le contenu sera en markdown (organisé suivant la
structure visible dans le fichier `doc/architecture/_template.md`

## Consequences

L'équipe devra écrire et commenté les décisions d'architecture qu'elle souhaite
prendre.

Nous pouvons aussi envisager d'utiliser ces fichiers pour soumettre une
proposition de modification d'architecture par le biais d'une revue (à
l'occasion d'une demande de fusion). L'équipe prendra soin, dans cette
situation, de reporter une partie des échanges qui aurons eu lieu dans un autre
endroit que le fichier d'enregistrement de la décision.


