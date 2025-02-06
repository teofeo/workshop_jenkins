
# Workshop Docker & Jenkins avec GitHub

## Introduction

Dans ce workshop, nous allons explorer les étapes suivantes :

1. Lancer des conteneurs Docker.
2. Récupérer le mot de passe de Jenkins après lancement.
3. Configurer GitHub et Jenkins pour intégrer une pipeline de build.
4. Créer et tester un projet.

### Prérequis

* Docker installé sur votre machine.
* Un compte GitHub.
* Accès à une machine pour exécuter Jenkins.

---

## Étape 1 : Lancer un conteneur Docker avec Jenkins et ngrok

### 1.1 Build le Dockerfile pour Jenkins

Récupérer le Dockerfile pour Jenkins avec `make` et `gcc` installés :

```bash
FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y make gcc && \
    apt-get clean

USER jenkins
```

Lancer la commande pour construire l'image Docker Jenkins :

```bash
docker build -t my-jenkins .
```

### 1.2 Lancer le conteneur Docker Jenkins

Une fois l'image construite, lancez un conteneur avec Jenkins. Nous allons également configurer un volume pour persister les données (comme les configurations de Jenkins).

```bash
docker run -d --name jenkins-container -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home my-jenkins
```

Cela lance Jenkins sur le port 8080 et crée un volume Docker nommé `jenkins_home` pour sauvegarder les données de Jenkins.

### 1.3 Lancer un conteneur Docker avec ngrok

Ensuite, pour exposer Jenkins de manière sécurisée via HTTPS à l'aide de ngrok, lancez un conteneur Docker avec ngrok.

Tout d'abord, créez-vous un compte sur ngrok :

Maintenant, lancez le conteneur ngrok :

```bash
docker run -it -e NGROK_AUTHTOKEN=<token> ngrok/ngrok http 8080
```

* Remplacez `your_ngrok_auth_token` par votre token d'authentification ngrok (obtenu via [ngrok.com](https://ngrok.com/)).
* Le conteneur ngrok crée un tunnel HTTPS pointant vers le port 8080 du conteneur Jenkins.
* Le port 4040 expose un tableau de bord de ngrok accessible à l'adresse `http://localhost:4040`.

### 1.4 Accéder à Jenkins via ngrok

Une fois ngrok lancé, vous recevrez une URL HTTPS générée, comme par exemple :

```
https://abcd-1234.ngrok.io
```

Utilisez cette URL pour accéder à Jenkins à la place de `http://localhost:8080`.

### 1.5 Récupérer le mot de passe Jenkins

Le mot de passe pour se connecter à Jenkins est généré automatiquement lors du premier démarrage. Pour le récupérer, exécutez cette commande dans votre terminal :

```bash
docker exec jenkins-container cat /var/jenkins_home/secrets/initialAdminPassword
```

Copiez le mot de passe et utilisez-le pour vous connecter à Jenkins via l'URL fournie par ngrok.

---

Cela devrait permettre d'exposer Jenkins via HTTPS en utilisant ngrok, tout en conservant la persistance des données grâce au volume Docker.

## Étape 2 : Configurer GitHub avec Jenkins

### 2.1 Créer un dépôt GitHub

Créez un dépôt GitHub pour votre projet. Ce dépôt contiendra le code source de votre projet ainsi qu'un fichier `Jenkinsfile` pour la pipeline.

### 2.2 Ajouter Jenkins comme un Webhook dans GitHub

1. Dans votre dépôt GitHub, allez dans **Settings** > **Webhooks** >  **Add webhook** .
2. Utilisez l'URL de Jenkins, par exemple `https://b30e-163-5-3-18.ngrok-free.app/github-webhook/` comme URL de webhook.
3. Configurez le webhook pour envoyer des notifications sur les pushs vers la branche principale.

### 2.3 Installer le plugin GitHub dans Jenkins

1. Accédez à **Manage Jenkins** >  **Manage Plugins** .
2. Installez le plugin **GitHub Integration Plugin** pour permettre à Jenkins de se connecter à GitHub.

### 2.4 Créer un Job Jenkins pour le projet

1. Allez dans **New Item** dans Jenkins et choisissez  **Pipeline** .
2. Dans la configuration du job, configurez le lien vers votre dépôt GitHub et le fichier `Jenkinsfile`.

Exemple de configuration :

* **Repository URL** : `https://github.com/username/your-repo.git`
* **Credentials** : Ajoutez les credentials de votre compte GitHub.

### 2.5 Configuration de la pipeline dans Jenkins

Dans votre fichier `Jenkinsfile` à la racine de votre dépôt, définissez une pipeline simple pour construire votre projet. Exemple :

```groovy
pipeline {
    agent any

    environment {
        WORKSPACE_DIR = 'workspace'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'make'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/workshop_jenkins', allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo 'Build Successful!'
            archiveArtifacts artifacts: '**/workshop_jenkins', allowEmptyArchive: true
        }
        failure {
            echo 'Build Failed!'
            archiveArtifacts artifacts: '**/workshop_jenkins', allowEmptyArchive: true
        }
    }
}
```

---

## Étape 3 : Tester la pipeline

### 3.1 Push sur GitHub

Effectuez un push de votre code vers la branche principale de votre dépôt GitHub. Cela déclenchera automatiquement la pipeline Jenkins.

### 3.2 Surveiller l'exécution

Retournez sur l'interface web de Jenkins pour surveiller l'exécution de votre pipeline. Vous pourrez voir chaque étape dans le job Jenkins et vérifier que tout fonctionne correctement.

---

## Conclusion

Félicitations ! Vous avez maintenant un environnement de CI/CD fonctionnel avec Docker, Jenkins, et GitHub. Vous pouvez étendre ce setup pour ajouter des tests automatisés, des déploiements, et d'autres fonctionnalités selon vos besoins.
