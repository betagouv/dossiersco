# Structure le fichier de locale

Status: _acceptée_

## Contexte

Il existe plusieurs façons de structurer les locales :
- clés absolues (qui permettent une grande liberté de structurer par domaine fonctionnel ou technique, ...) ou clés relatives à l'arborescence proposée par Rails


## Decision

Nous choisissons les clés relatives :
- pour avoir des clés plus courtes à manipuler
- tous les textes du même écran sont regroupés
