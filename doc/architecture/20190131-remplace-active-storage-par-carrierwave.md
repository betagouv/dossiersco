# Remplace ActiveStorage par Carrierwave

Status: _acceptée_

## Contexte

- ActiveStorage est un module de Rails très récent, et peu documenté.
- Nous avons passé beaucoup de temps à essayer de faire fonctionner l'upload, sans succès
- Nous souhaitons à terme utiliser un object store français, sûrement celui d'OVH. ActiveStorage n'a pas actuellement de service pour openstack (techno utilisée pour l'object storage d'OVH)

## Decision

_On revient sur CarrierWave_

