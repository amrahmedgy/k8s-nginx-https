#!/bin/bash
minikube start
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl apply -f deployment.yaml -f ingress.yaml
echo "Access the app at: https://myapp.$(minikube ip | tr '.' '-').nip.io"
