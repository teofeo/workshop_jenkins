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
