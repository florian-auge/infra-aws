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