# repo-infra-k8s

Terraform do EKS, VPC, ECR e recursos K8s da API de Oficina Mecânica (Fase 3, FIAP 13SOAT — Grupo 72).

## Arquitetura

![Componentes](https://raw.githubusercontent.com/JairNunes/repo-app/main/diagrams/01-componentes.png)

Esse repo provisiona o bloco `EKS Cluster` (centro-direita) — VPC, nodes t3.medium, namespace `auto-repair-shop`, deployment com HPA 2-10, NLB Service e ECR. Conexão com o `RDS PostgreSQL` (canto inferior) sai do Pod via Prisma. Fontes editáveis em [`repo-app/diagrams/`](https://github.com/JairNunes/repo-app/tree/main/diagrams).

## Stack

- AWS EKS 1.29 em 2 AZ
- VPC custom (subnets públicas e privadas, NAT Gateway)
- Node group `t3.medium`, min 2 / max 4
- HPA min 2 / max 10, CPU 70%, memória 80%
- ECR repository
- Terraform 1.7.5 + provider AWS 5.40 + kubernetes 2.30
- GitHub Actions

## Estrutura

```
modules/
├── vpc/             VPC, subnets, IGW, NAT, route tables
├── eks/             EKS, node group, OIDC, ECR
└── k8s-resources/   namespace, configmap, secret, deployment, service, HPA
environments/
└── prod/            composição dos módulos + backend S3
```

## Pré-requisitos

- `repo-infra-db` provisionado (precisa do `DATABASE_URL`)
- `repo-lambda-auth` provisionado (precisa do `NOTIFY_LAMBDA_URL`)
- Conta New Relic com license key
- Bucket S3 + DynamoDB pro state (instruções no README do `repo-infra-db`)

## Rodando local

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

aws eks update-kubeconfig --name oficina-mecanica-eks --region us-east-1
kubectl get nodes
kubectl get pods -n auto-repair-shop
```

## Deploy

Push em `main` dispara o pipeline: `validate` → `plan` → `apply` com approval manual.

Secrets necessários: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DATABASE_URL`, `JWT_SECRET`, `ADMIN_PASSWORD`, `NEW_RELIC_LICENSE_KEY`, `NOTIFY_LAMBDA_URL`.

## Custos

- EKS control plane: ~US$73/mês (não tem free tier)
- 2× t3.medium ON_DEMAND: ~US$60/mês
- NAT Gateway + EIP: ~US$32/mês + tráfego
- NLB: ~US$16/mês
- ECR: US$0 dentro do free tier

Total se rodando 24/7: ~US$180/mês. Estratégia acadêmica é subir, gravar, derrubar no mesmo dia (~US$5/dia).

## Branch protection

`main` protegida — PR obrigatório, sem commit direto.
