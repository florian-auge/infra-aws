# infra-aws
Infrastructure AWS personnelle - projet de reconversion DevOps.

## Stack
- **IaC** : Terraform (backend distant S3 + DynamoDB pour state et locking)
- **Configuration** : Ansible
- **Serverless** : Lambda (Python)
- **Base de données** : MariaDB sur RDS
- **Conteneurs** : Docker

## Structure
infra-aws/
├── bootstrap/    # Création du backend Terraform (bucket S3 + table DynamoDB), state local
├── terraform/    # Infrastructure as Code (backend.tf, vpc.tf, ...)
│   └── _legacy/  # Ancien main.tf monolithique, conservé en référence
├── ansible/      # Configuration automatisée
├── lambda/       # Fonctions serverless
└── docker/       # Conteneurs

## Projets liés
Cette infrastructure héberge [devops-trainer](https://github.com/flo-devops-lab/devops-trainer), une plateforme d'entraînement DevOps par scénarios.

## Configuration
Copier `terraform/terraform.tfvars.example` en `terraform/terraform.tfvars` et renseigner ses propres valeurs (non commité, voir `.gitignore`).

## Roadmap / limites connues
- Durcissement réseau : l'app Flask (port 5000) est actuellement exposée publiquement sans TLS ni authentification. Prochaine étape : passer par un ALB avec certificat TLS et restreindre l'accès direct à l'instance.
- Découpage des security groups en ressources séparées (`aws_vpc_security_group_ingress_rule`) plutôt qu'en règles inline, pour une gestion plus modulaire.
- Reconstruction complète de l'infra Terraform en cours, brique par brique (réseau terminé : VPC/subnets/IGW/routing ; à venir : security groups, EC2, RDS), en parallèle de l'infra existante conservée comme filet de sécurité jusqu'à bascule complète.
- Ajout de tests automatisés sur le pipeline CI/CD.
