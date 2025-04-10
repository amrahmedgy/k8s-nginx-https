# Kubernetes NGINX with HTTPS via nip.io

Deploy an NGINX app on Kubernetes (Minikube) with HTTPS using `nip.io` for DNS.

## 🚀 Prerequisites
- [Minikube](https://minikube.sigs.k8s.io/docs/) (local Kubernetes)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) (for Ingress Controller)

## 📝 Steps

### 1. Start Minikube
```bash
minikube start
minikube ip  # Note the IP (e.g., `192.168.49.2`)
