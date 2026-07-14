## Port déjà alloué (simple)
**Symptôme** : "port is already allocated"
**Cause** : ancien conteneur pas arrêté avant nouveau `docker run`
**Fix** : docker stop $(docker ps -q)
**Vu le** : 8 mai 2026 (local WSL)

## SSH inaccessible après restriction du security group
**Symptôme** : le job GitHub Actions échoue à se connecter en SSH à l'instance EC2 (timeout / connexion refusée)
**Cause** : le security group avait été restreint à mon IP personnelle uniquement (bonne pratique sécurité), 
mais les runners GitHub Actions utilisent des IPs dynamiques différentes à chaque exécution — 
donc le pipeline ne peut plus joindre l'instance.
**Fix temporaire** : rouvrir le port 22 à 0.0.0.0/0 pour débloquer le déploiement immédiat.
**Vrai fix à prévoir** : migrer vers AWS SSM Session Manager, qui ne nécessite pas d'ouvrir le port 22 
du tout (connexion via l'API AWS/IAM plutôt que réseau direct).
**Vu le** : 5 juillet 2026
**Note** : c'est ce fix temporaire (port 22 rouvert) qui a probablement déstabilisé le daemon Docker 
sur l'instance, provoquant l'incident suivant (permission denied + port already allocated).

## Permission denied + port alloué (daemon bloqué)
**Symptôme** : "cannot stop container: permission denied" + "port already allocated"
**Cause** : daemon Docker qui ne répond plus correctement (probablement lié à l'incident réseau SG/port 22)
**Fix** : sudo systemctl restart docker && sudo docker rm -f $(sudo docker ps -aq)
**Vu le** : 5 juillet 2026 (EC2 prod, via pipeline)

## BucketAlreadyExists lors de la création S3
**Symptôme** : "BucketAlreadyExists: The requested bucket name is not available"
**Cause** : les noms de bucket S3 sont uniques à l'échelle mondiale, pas seulement au sein de mon compte AWS
**Fix** : renommage du bucket avec un préfixe personnel (`flo-tf-boot-bucket`) pour garantir l'unicité
**Vu le** : 14 juillet 2026 (bootstrap Terraform backend)

## AccessDeniedException dynamodb:CreateTable
**Symptôme** : "User: florian-dev is not authorized to perform: dynamodb:CreateTable"
**Cause** : policy IAM de `florian-dev` volontairement restreinte, n'incluait aucune permission DynamoDB (jamais utilisé ce service avant)
**Fix** : création d'une policy IAM custom, scopée à l'ARN exact de la table (pas de policy managée type `AmazonDynamoDBFullAccess`, trop permissive)
**Vu le** : 14 juillet 2026 (bootstrap Terraform backend)

## AccessDeniedException en cascade sur attributs computed DynamoDB
**Symptôme** : après un `CreateTable` réussi, erreurs successives sur `dynamodb:DescribeContinuousBackups`, puis `dynamodb:DescribeTimeToLive`, puis `dynamodb:ListTagsOfResource`
**Cause** : le provider Terraform AWS effectue plusieurs appels de lecture après création pour peupler les attributs "computed" de la resource (PITR, TTL, tags) : chaque appel nécessite sa propre permission IAM, non listée de façon exhaustive dans la doc officielle
**Fix** : ajout progressif de chaque action manquante à la policy IAM custom, jusqu'à couverture complète
**Vu le** : 14 juillet 2026 (bootstrap Terraform backend)

## Resource DynamoDB "tainted" après apply échoué
**Symptôme** : `terraform plan` suivant affiche "is tainted, so must be replaced" (`destroy` puis `create` au lieu d'un simple state OK)
**Cause** : le premier `apply` avait échoué en cours de création (erreurs IAM ci-dessus) ; Terraform ne pouvait plus faire confiance à l'état partiel de la ressource
**Fix** : aucune action corrective nécessaire - comportement normal et sûr de Terraform (destroy + recreate propre au prochain apply)
**Vu le** : 14 juillet 2026 (bootstrap Terraform backend)
