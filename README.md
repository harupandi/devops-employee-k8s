# DevOps Employee — Kubernetes

Project simulating an Employee platform and its CI/CD repositories and pipelines. This is the k8s repository that handles AKS/ArgoCD manifests deployment and configuration.

Other related repositories:

* [Terraform infrastructure repository](https://github.com/harupandi/devops-employee-infrastructure)
* [Backend repository](https://github.com/harupandi/devops-employee-backend)
* [Frontend repository](https://github.com/harupandi/devops-employee-frontend)

## ArgoCD

* Installed using Helm provider in [terraform](https://github.com/harupandi/devops-employee-infrastructure) repository
* For first-time cluster creation, bootstrap workflow runs `kubectl apply -f argocd/applications/devops-employee-*.yml` based on environment selection

## Environments

Each environment (dev/qa/prod) is configured using Helm charts and contains:

* Template configuration for `frontend`, `backend`, and `gateway` services
* Default `values.yaml` file
* Each environment provides their own `values-*.yaml` file for docker image configuration
* User Assigned Managed Identity (UAMI) for AKS networking (Azure CNI)
* ACR pull permissions for the AKS kubelet identity
* Istio Gateway API implementation

## Flow
1. Backend/Frontend repositories build and push immutable docker images to Azure Container Registry using git commit SHA
2. Backend/Frontend repositories automatically update `values-dev.yaml` to reflect the new image on the Dev environment
3. Once the image is tested, promotion to QA can be manually triggered, which automatically picks the Dev image from `values-dev.yaml` and changes `values-qa.yaml` to use the exact same image

## Roadmap

* [ ] Add Helm lint
* [ ] Add Secret scanning
* [ ] Add Helm template validation
* [ ] Add kubeconform
* [ ] Promote to prod

The goal is to keep AKS configuration version-controlled and managed through ArgoCD for GitOps style CD.
