# repo-infra-k8s

Terraform que provisiona o **cluster EKS** + **VPC** + **ECR** + **K8s resources** para a API da Oficina Mecânica (Fase 3, FIAP 13SOAT — Grupo 72).

## Stack

- AWS EKS 1.29
- VPC custom (2 AZ, públicas + privadas, NAT Gateway)
- Worker nodes `t3.medium`, min 2 / max 4
- HPA min 2 / max 10, thresholds CPU 70% e memória 80%
- ECR repository pra imagem da app
- Terraform 1.7.5 + provider AWS 5.40 + kubernetes 2.30
- GitHub Actions (CI/CD)

## Estrutura

```
modules/
├── vpc/             → VPC, subnets, IGW, NAT, route tables
├── eks/             → EKS cluster, node group, OIDC, ECR
└── k8s-resources/   → namespace, configmap, secret, deployment, service, HPA
environments/
└── prod/            → composição dos módulos + backend S3
```

## Pré-requisitos

1. `repo-infra-db` provisionado (precisa de `DATABASE_URL`)
2. `repo-lambda-auth` provisionado (precisa de `NOTIFY_LAMBDA_URL`)
3. Conta New Relic com license key
4. Bucket S3 + DynamoDB pra Terraform state remoto (instruções no `repo-infra-db/backend.tf`)

## Como rodar localmente

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# preencher secrets em terraform.tfvars OU exportar TF_VAR_*
export TF_VAR_database_url='postgresql://...'
export TF_VAR_jwt_secret='...'
export TF_VAR_admin_password='...'
export TF_VAR_new_relic_license_key='...'

terraform init
terraform plan
terraform apply

# Configurar kubectl
aws eks update-kubeconfig --name oficina-mecanica-eks --region us-east-1
kubectl get nodes
kubectl get pods -n auto-repair-shop
```

## Deploy via GitHub Actions

Push em `main` → `validate` → `plan` → `apply` automático (com approval manual no environment `production`).

**Secrets necessários:**

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `DATABASE_URL` (do `repo-infra-db`)
- `JWT_SECRET`
- `ADMIN_PASSWORD`
- `NEW_RELIC_LICENSE_KEY`
- `NOTIFY_LAMBDA_URL` (do `repo-lambda-auth`)

## Custos estimados

- EKS control plane: **~US$73/mês** (não tem free tier)
- 2× `t3.medium` ON_DEMAND: **~US$60/mês**
- NAT Gateway + EIP: **~US$32/mês + tráfego**
- Network LoadBalancer (Service): **~US$16/mês**
- ECR: **US$0** dentro do free tier
- **Total: ~US$180/mês** se mantido rodando 24/7

**Estratégia acadêmica:** subir, gravar vídeo, executar `terraform destroy` no mesmo dia (~US$5/dia de uso).

## Diagrama

```
            ┌──────────────────────────────────────────────────────┐
            │                AWS Cloud (us-east-1)                  │
            │                                                       │
            │   ┌─────────────────────────────────────────────┐     │
            │   │              VPC 10.0.0.0/16                │     │
            │   │                                             │     │
            │   │  Public subnet (10.0.0.0/24)   ◀── ALB/NLB │     │
            │   │     ↓                                       │     │
            │   │  NAT Gateway                                │     │
            │   │     ↓                                       │     │
            │   │  Private subnet (10.0.10.0/24)              │     │
            │   │     │                                       │     │
            │   │     ▼                                       │     │
            │   │  ┌──────────────────────────────────┐       │     │
            │   │  │  EKS Cluster (oficina-mecanica)  │       │     │
            │   │  │  Node group: t3.medium x 2-4    │       │     │
            │   │  │  Pods: api (HPA 2-10)            │       │     │
            │   │  └──────────────────────────────────┘       │     │
            │   └─────────────────────────────────────────────┘     │
            │                                                       │
            │   ECR ◀─── docker push (CI/CD)                       │
            │   RDS PostgreSQL (repo-infra-db)                     │
            └──────────────────────────────────────────────────────┘
```

## Branch protection

`main`: PR obrigatório, status checks, sem commits diretos.
