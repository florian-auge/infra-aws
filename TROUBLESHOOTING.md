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