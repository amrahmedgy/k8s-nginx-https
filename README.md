# 🚀 Kubernetes NGINX Deployment with nip.io DNS

Deploy NGINX on Kubernetes with automatic HTTPS redirection using nip.io for DNS resolution. Perfect for local development and testing environments without requiring DNS configuration.

## 🌟 Overview

This project provides a streamlined way to deploy NGINX on a local Kubernetes cluster using nip.io DNS resolution. It enables automatic HTTPS redirection and simplifies local development and testing with a real domain-like experience.

## 📦 Prerequisites

Before getting started, ensure you have the following tools installed:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) - Local Kubernetes cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [Helm](https://helm.sh/docs/intro/install/) (optional) - Package manager for Kubernetes

## 🛠️ Project Structure

```
.
├── README.md         - This documentation
├── deployment.yaml   - NGINX deployment and service configuration
├── ingress.yaml      - Ingress configuration with nip.io host
└── setup.sh          - One-click setup script (optional)
```

## 🚀 Quick Start Guide

Follow these steps to get your NGINX deployment up and running:

### 1. Start Minikube

Launch your local Kubernetes cluster and note the IP address for later use:

```bash
minikube start
minikube ip  # Note the IP (e.g., 192.168.49.2)
```

### 2. Enable Ingress Controller

Enable the NGINX Ingress controller in your Minikube:

```bash
minikube addons enable ingress
```

### 3. Update Ingress Configuration

Edit `ingress.yaml` to use your Minikube IP address:

```bash
# Replace the IP in host with your Minikube IP
# From: myapp.192-168-49-2.nip.io
# To: myapp.YOUR-MINIKUBE-IP.nip.io (replace dots with dashes)
sed -i 's/myapp.192-168-49-2.nip.io/myapp.'$(minikube ip | tr '.' '-')'.nip.io/' ingress.yaml
```

### 4. Deploy Application

Apply the Kubernetes configuration files:

```bash
kubectl apply -f deployment.yaml -f ingress.yaml
```

### 5. Run Tunnel (in a separate terminal)

Create a network route to your Kubernetes services:

```bash
minikube tunnel
```

### 6. Access Your Application

Access your deployed NGINX via the nip.io domain:

```bash
# Using curl
curl http://myapp.$(minikube ip | tr '.' '-').nip.io

# Or open in your browser:
# http://myapp.192-168-49-2.nip.io (replace with your IP)
```

## 🔍 Detailed Configuration

### Deployment Configuration (`deployment.yaml`)

This configuration sets up an NGINX Deployment with one replica and exposes it via a Service:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

### Ingress Configuration (`ingress.yaml`)

This configures the Ingress resource for routing external traffic to your service using nip.io:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: "myapp.192-168-49-2.nip.io" # Replace with your Minikube IP
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

## 🚨 Troubleshooting Guide

### No Ingress IP Address

If you can't access your application through the Ingress:

```bash
# 1. Check if tunnel is running
minikube tunnel

# 2. Verify ingress controller is running
kubectl get pods -n ingress-nginx

# 3. Check ingress status
kubectl describe ingress nginx-ingress
```

### Connection Refused

If you receive a connection refused error:

```bash
# 1. Test direct pod access
kubectl port-forward pod/$(kubectl get pod -l app=nginx -o name | sed 's|pod/||') 8080:80
curl localhost:8080  # Should show NGINX welcome page

# 2. Check service endpoints
kubectl get endpoints nginx

# 3. Verify service is running
kubectl get svc nginx
```

### HTTPS Redirection Issues

If HTTPS redirection isn't working:

```bash
# Add this annotation to ingress.yaml and reapply
nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

kubectl apply -f ingress.yaml
```

## 🔄 Alternative Access Methods

### 1. NodePort Access

Access your application directly through a NodePort:

```bash
# Expose service as NodePort
kubectl patch svc nginx -p '{"spec":{"type":"NodePort"}}'

# Access using Minikube IP and NodePort
curl http://$(minikube ip):$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}')
```

### 2. Port Forward to Ingress Controller

Forward a local port directly to the Ingress controller:

```bash
# Forward local port 8080 to ingress controller
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Access with the correct Host header
curl -H "Host: myapp.192-168-49-2.nip.io" http://localhost:8080
```

## 🏗️ Future Enhancements

Here are some ways to extend this project:

1. **Add HTTPS with Cert-Manager**
   - Implement automatic TLS certificate provisioning

2. **Set up CI/CD Pipeline**
   - Configure GitHub Actions for automated testing and deployment

3. **Custom Domain Integration**
   - Replace nip.io with a custom domain for production use

4. **Monitoring and Logging**
   - Add Prometheus and Grafana for metrics monitoring
   - Implement ELK stack for centralized logging

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [nip.io Documentation](https://nip.io/)

## 📜 License

MIT
