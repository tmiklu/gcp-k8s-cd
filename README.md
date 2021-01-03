# Multi-zonal GKE cluster 
## (1x control plane, 3x worker nodes) 
* europe-west3-a (master|worker)
* europe-west3-b worker
* europe-west3-c worker
## Requirements 
* terraform v0.14 
* gcloud 

## Inicialize terraform project

1. cd gcp-k8s-cd/terraform && terraform init 
2. terraform plan 
3. terraform apply 