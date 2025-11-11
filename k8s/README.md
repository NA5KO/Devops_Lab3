Kubernetes manifests for mon-app

- deployment.yaml: Deployment resource (uses image `your-dockerhub/mon-app:latest`)
- service.yaml: ClusterIP service exposing port 80

You can apply them with:

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
