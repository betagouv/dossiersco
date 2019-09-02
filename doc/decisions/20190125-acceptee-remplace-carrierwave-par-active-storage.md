# Remplace Carrierwave par ActiveStorage

## Contexte

- Lorsque nous utilisions le framework Sinatra, nous utilisions Carrierwave pour l'upload de fichiers.
- Nous avons migré de Sinatra à Rails

- Rails 5 permet grâce à ActiveStorage d'uploader et de référencer simplement des documents dans des services de cloud (comme Amazon S3, Google Cloud Storage ou Microsoft Azure Storage)

## Decision

Nous choisissons de ne plus utiliser Carrierwave et de s'appuyer maintenant sur ActiveStorage pour simplifier la configuration (et limiter le nombre de librairie que nous utilisons)

## Conséquences

- lorsque nous stockerons nos fichiers sur l'object storage d'ovh, nous devrons développer un service openstack qui hérite de https://github.com/rails/rails/blob/master/activestorage/lib/active_storage/service.rb
