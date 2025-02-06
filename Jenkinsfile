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

        stage('Install dependencies') {
            steps {
                sh 'sudo apt-get update && sudo apt-get install -y build-essential'
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
        }
        failure {
            echo 'Build Failed!'
        }
    }
}
