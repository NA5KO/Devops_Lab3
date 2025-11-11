# Devops_Lab3

Ce dépôt contient un exemple minimal pour réaliser la Partie 3 (déploiement Kubernetes sans Helm)
et la Partie 4 (déploiement avec Helm) du lab Jenkins CI/CD.

Contenu principal:

- `Dockerfile`, `index.html` : une petite application statique (serveur nginx) à dockeriser.
- `k8s/deployment.yaml`, `k8s/service.yaml` : manifests Kubernetes pour déployer sans Helm.
- `mon-app/` : chart Helm minimal (Chart.yaml, values.yaml, templates/).
- `Jenkinsfile-nohelm` : pipeline Jenkins pour construire, pousser l'image puis déployer avec `kubectl`.
- `Jenkinsfile-helm` : pipeline Jenkins qui utilise Helm pour déployer le chart.

Remarques générales
-------------------

1) Remplacez `your-dockerhub/mon-app` par votre compte Docker Hub (ou un registry accessible depuis Jenkins/cluster).
2) Créez dans Jenkins une credential de type "Username with password" avec l'ID `dockerhub-creds` contenant vos identifiants Docker Hub.
3) Assurez-vous que l'agent Jenkins qui exécute les étapes possède `docker`, `kubectl` (et `helm` pour la variante Helm).
	 - Si Jenkins tourne dans un conteneur Docker, vous pouvez soit :
		 - exécuter un agent externe (VM/WSL) avec docker/kubectl/helm installés, ou
		 - lancer Jenkins avec accès au socket Docker et monter votre kubeconfig (avancé). Exemple pour tests locaux :

			 docker run -d -p 8080:8080 -p 50000:50000 \
				 -v jenkins_home:/var/jenkins_home \
				 -v %USERPROFILE%/.kube:/var/jenkins_home/.kube \
				 jenkins/jenkins:lts

			 (Sous WSL/Windows adaptez le chemin de `~/.kube` ; ceci monte le kubeconfig pour que `kubectl` puisse se connecter au cluster.)

Comment utiliser les Jenkinsfiles
--------------------------------

1) Pousser ce dépôt sur GitHub (ou un Git accessible par votre Jenkins).
2) Dans Jenkins :
	 - Créer un nouvel item -> Pipeline
	 - Dans la section "Pipeline", choisir "Pipeline script from SCM" -> Git
	 - Indiquer l'URL du dépôt et la branche
	 - Pour la pipeline sans Helm : mettre `Script Path` = `Jenkinsfile-nohelm`
	 - Pour la pipeline Helm : mettre `Script Path` = `Jenkinsfile-helm`
3) Créez la credential `dockerhub-creds` (ID exact utilisé dans les Jenkinsfiles).

Tests locaux rapides
--------------------

1) Construire l'image localement :

	 docker build -t your-dockerhub/mon-app:localtest .

2) Lancer l'image localement :

	 docker run --rm -p 8081:80 your-dockerhub/mon-app:localtest

	 Puis ouvrir http://localhost:8081 pour vérifier l'application.

Déploiement Kubernetes (manuel)
--------------------------------

Modifier `k8s/deployment.yaml` pour utiliser l'image correcte (ex: `your-dockerhub/mon-app:latest`) puis :

	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

Vérifier :

	kubectl get pods -l app=mon-app
	kubectl get svc mon-app-service

Déploiement avec Helm (manuel)
------------------------------

Depuis la racine du repo :

	helm upgrade --install mon-app ./mon-app --set image.repository=your-dockerhub/mon-app --set image.tag=latest

Points d'attention / conseils
-----------------------------

- Les Jenkinsfiles fournis sont des exemples : adaptez `git` URL, le nom d'image et la gestion des credentials.
- Assurez-vous que `kubectl` a accès à votre cluster (kubeconfig valide dans l'environnement Jenkins ou usage d'un agent avec accès).
- Pour un Jenkins conteneurisé, il est souvent plus simple d'utiliser un agent dédié (node/VM) qui a docker/kubectl/helm installés.

Support & suite
---------------

Si vous voulez, j'ajoute :

- un job Jenkinsfile configuré automatiquement (declarative seed job), ou
- un pipeline Jenkinsfile monolithique qui détecte si Helm est présent et choisit la méthode.

Fichiers ajoutés automatiquement pour le lab : `Jenkinsfile-nohelm`, `Jenkinsfile-helm`, `k8s/*`, `mon-app/*`.
