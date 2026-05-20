INSERT INTO scenarios (title, context, difficulty) VALUES
(
  'Le pipeline silencieux',
  'Un développeur vient de pusher sur la branche main. Le pipeline GitHub Actions ne se déclenche pas. Aucune erreur visible dans l\'interface. L\'EC2 tourne normalement et l\'application répond, mais sur l\'ancienne version du code. Le déploiement automatique est silencieusement cassé.',
  'easy'
),
(
  '502 au réveil',
  'Lundi matin, 8h. L\'ALB renvoie des erreurs 502 à tous les utilisateurs. Les tâches ECS Fargate redémarrent en boucle. La RDS PostgreSQL est saine, aucune erreur côté base. Le dernier déploiement date de vendredi soir.',
  'medium'
),
(
  'Le bucket qui coûte',
  'Fin de mois. La facture AWS est anormalement élevée. Personne n\'a touché à l\'infra depuis deux semaines. Aucune alarme CloudWatch n\'était configurée sur les coûts. Il faut identifier la source avant que ça empire.',
  'hard'
);