SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE results;
TRUNCATE TABLE sessions;
TRUNCATE TABLE options;
TRUNCATE TABLE questions;
TRUNCATE TABLE scenarios;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO scenarios (title, context, difficulty) VALUES
(
  'Le pipeline silencieux',
  'Un développeur vient de pusher sur la branche main. Le pipeline GitHub Actions ne se déclenche pas. Aucune erreur visible dans l\'interface. L\'EC2 tourne normalement et l\'application répond, mais sur l\'ancienne version du code. Le déploiement automatique est silencieusement cassé.',
  'junior'
),
(
  '502 au réveil',
  'Lundi matin, 8h. L\'ALB renvoie des erreurs 502 à tous les utilisateurs. Les tâches ECS Fargate redémarrent en boucle. La RDS PostgreSQL est saine, aucune erreur côté base. Le dernier déploiement date de vendredi soir.',
  'confirmed'
),
(
  'Le bucket qui coûte',
  'Fin de mois. La facture AWS est anormalement élevée. Personne n\'a touché à l\'infra depuis deux semaines. Aucune alarme CloudWatch n\'était configurée sur les coûts. Il faut identifier la source avant que ça empire.',
  'senior'
);

-- Questions scénario 1 : Le pipeline silencieux
INSERT INTO questions (question_text, scenario_id) VALUES
('Le pipeline GitHub Actions ne s\'est pas déclenché après un push sur main. Quelle est la première chose que vous vérifiez ?', 1),
('Le workflow existe dans le repo mais n\'apparaît jamais dans l\'historique des exécutions. Quelle configuration du fichier YAML est à vérifier en priorité ?', 1),
('Le fichier .github/workflows/deploy.yml contient on: push: branches: [master]. La branche de travail est main. Que faites-vous ?', 1);

-- Options Q1
INSERT INTO options (option_text, score, explication, question_id) VALUES
('L\'onglet Actions sur GitHub pour voir si le workflow apparaît', 1, 'C\'est le point d\'entrée naturel — GitHub Actions affiche directement l\'historique des déclenchements et les erreurs éventuelles.', 1),
('Les logs CloudWatch sur AWS', 0, 'CloudWatch surveille l\'infra AWS, pas le pipeline GitHub. Le problème est en amont.', 1),
('L\'état de l\'EC2 dans la console AWS', 0, 'L\'EC2 tourne normalement — le problème est dans le déclenchement du pipeline, pas dans l\'infra.', 1),
('Le fichier Dockerfile du projet', 0, 'Le Dockerfile n\'a aucun lien avec le déclenchement du pipeline.', 1);

-- Options Q2
INSERT INTO options (option_text, score, explication, question_id) VALUES
('La section on: qui définit le déclencheur', 1, 'C\'est elle qui définit sur quelle branche le pipeline se déclenche. Mal configurée, le workflow existe mais ne tourne jamais.', 2),
('La section jobs: qui définit les étapes', 0, 'Les jobs ne s\'exécutent que si le déclencheur a fonctionné — le problème est en amont.', 2),
('Le secret EC2_HOST dans les settings GitHub', 0, 'Les secrets interviennent pendant l\'exécution, pas au déclenchement.', 2),
('La version de Node.js utilisée par le runner', 0, 'La version du runtime n\'empêche pas le déclenchement du workflow.', 2);

-- Options Q3
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Renommer la branche main en master sur GitHub', 0, 'Mauvaise direction — on ne renomme pas une branche pour coller à une erreur de config.', 3),
('Supprimer le fichier workflow et le recréer', 0, 'Inutile — le problème est une seule ligne mal configurée.', 3),
('Modifier le Dockerfile pour cibler main', 0, 'Le Dockerfile n\'a aucun lien avec le déclenchement du pipeline.', 3),
('Remplacer master par main dans le fichier YAML', 1, 'C\'est le fix exact — le déclencheur doit correspondre au nom réel de la branche.', 3);

-- Questions scénario 2 : 502 au réveil
INSERT INTO questions (question_text, scenario_id) VALUES
('L\'ALB renvoie des erreurs 502 à tous les utilisateurs. Quelle est la première ressource que vous consultez pour poser un diagnostic ?', 2),
('Les logs CloudWatch affichent : ERROR: could not connect to server - Connection refused sur db.internal:5432. Quelle est la cause la plus probable ?', 2),
('La variable DATABASE_URL est en doublon dans la task definition ECS — une ancienne et une nouvelle URL coexistent. Comment corrigez-vous le problème ?', 2);

-- Options Q4
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Les logs CloudWatch des tâches ECS Fargate', 1, 'Réflexe numéro 1 — les logs contiennent toujours la cause racine. L\'ALB est sain, le problème est dans les conteneurs derrière lui.', 4),
('La console RDS pour vérifier l\'état de la base', 0, 'L\'énoncé indique que la RDS est saine — vérifier la base en premier fait perdre du temps.', 4),
('Le Security Group de l\'ALB', 0, 'Le Security Group contrôle le trafic réseau entrant, pas les erreurs applicatives des conteneurs.', 4),
('Le Dockerfile de l\'application', 0, 'Le Dockerfile ne contient pas de config d\'environnement — ce n\'est pas là que se trouve la cause.', 4);

-- Options Q5
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Le Security Group de la RDS bloque le port 3306', 0, 'Le port mentionné dans l\'erreur est 5432 (PostgreSQL), pas 3306. Et "Connection refused" indique une mauvaise URL, pas un blocage réseau.', 5),
('Une variable d\'environnement DATABASE_URL est mal configurée dans la task definition', 1, '"Connection refused" sur une adresse db.internal pointe vers une URL incorrecte ou obsolète dans la configuration du conteneur.', 5),
('L\'ALB n\'est pas connecté au bon subnet', 0, 'L\'ALB distribue le trafic correctement — l\'erreur est applicative, pas réseau.', 5),
('L\'image Docker est corrompue', 0, 'Une image corrompue produirait une erreur au démarrage du conteneur, pas une erreur de connexion à la base.', 5);

-- Options Q6
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Modifier la variable DATABASE_URL directement dans la console ECS', 0, 'Toute modification manuelle en console est écrasée au prochain terraform apply — c\'est une correction temporaire qui crée de la dette technique.', 6),
('Corriger la task definition dans le fichier Terraform et relancer terraform apply', 1, 'La bonne pratique : l\'infra est définie dans le code. On corrige la source, on applique. La console ECS reflète, jamais l\'inverse.', 6),
('Redémarrer les tâches ECS depuis la console AWS', 0, 'Redémarrer sans corriger la config reproduit exactement le même crash.', 6),
('Modifier le fichier .env sur l\'EC2', 0, 'Les variables d\'environnement ECS Fargate sont dans la task definition, pas dans un fichier .env sur une instance.', 6);

-- Questions scénario 3 : Le bucket qui coûte
INSERT INTO questions (question_text, scenario_id) VALUES
('La facture AWS de fin de mois est anormalement élevée. Aucune alarme de coût n\'était configurée. Quel service AWS utilisez-vous en premier pour identifier la source du problème ?', 3),
('AWS Cost Explorer montre que S3 représente 80% de la facture ce mois-ci contre 5% habituellement. Quelle est la cause la plus probable ?', 3),
('Le bucket S3 accumule des fichiers de logs et de backups depuis des semaines sans nettoyage automatique. Quelle solution mettez-vous en place pour éviter que la situation se reproduise ?', 3);

-- Options Q7
INSERT INTO options (option_text, score, explication, question_id) VALUES
('AWS Cost Explorer', 1, 'Point d\'entrée FinOps — vue par service, par région, par jour. L\'anomalie est identifiable en 30 secondes.', 7),
('CloudWatch Metrics', 0, 'CloudWatch surveille les métriques techniques (CPU, mémoire). Il ne donne pas de vue consolidée des coûts par service.', 7),
('AWS Trusted Advisor', 0, 'Trusted Advisor donne des recommandations d\'optimisation, pas une analyse des coûts en temps réel.', 7),
('La console S3', 0, 'Aller directement dans S3 sans savoir que c\'est S3 le problème, c\'est chercher une aiguille dans une botte de foin.', 7);

-- Options Q8
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Une Elastic IP non associée facturée en continu', 0, 'Une EIP non associée coûte quelques centimes par heure — pas de quoi faire exploser une facture S3.', 8),
('Des fichiers qui s\'accumulent sans politique de cycle de vie — stockage qui explose', 1, 'Sans lifecycle policy, logs, backups et snapshots s\'accumulent indéfiniment. Le pipeline continue de déposer des fichiers, personne ne nettoie.', 8),
('Une instance EC2 oubliée qui tourne depuis deux semaines', 0, 'L\'anomalie est sur S3 spécifiquement, pas sur EC2.', 8),
('Des snapshots EBS facturés à la place de S3', 0, 'Les snapshots EBS apparaissent sous EC2 dans Cost Explorer, pas sous S3.', 8);

-- Options Q9
INSERT INTO options (option_text, score, explication, question_id) VALUES
('Supprimer manuellement les fichiers anciens chaque fin de mois', 0, 'Une action manuelle récurrente est une dette opérationnelle — elle sera oubliée. Ce n\'est pas une solution durable.', 9),
('Configurer une politique de cycle de vie S3 pour archiver ou supprimer automatiquement les objets anciens', 1, 'La lifecycle policy automatise le nettoyage — transition vers Glacier après X jours, suppression après Y jours. Zéro intervention manuelle.', 9),
('Migrer les fichiers vers un bucket dans une autre région moins chère', 0, 'Le transfert inter-régions est lui-même facturé — et ça ne résout pas l\'accumulation.', 9),
('Activer le versioning S3 pour mieux suivre les fichiers', 0, 'Le versioning multiplie les objets stockés — sans lifecycle policy associée, il aggrave exactement le problème.', 9);
