# infra-aws

Infrastructure AWS personnelle — projet de reconversion DevOps.

## Stack

- **IaC** : Terraform
- **Configuration** : Ansible
- **Serverless** : Lambda (Python)
- **Base de données** : MariaDB sur RDS
- **Conteneurs** : Docker

## Structure
infra-aws/
├── terraform/    # Infrastructure as Code
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
- Migration progressive du provisioning manuel (console) vers 100% Terraform, en cours de vérification (état actuel : drift entre l'instance EC2 en production et l'état Terraform, à résoudre).
- Ajout de tests automatisés sur le pipeline CI/CD.
