pipeline {
    agent {
        docker {
            image 'python:3.13'
            args '-u root:root'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'apt-get update && apt-get install -y zip'
                sh 'pip install -r requirements.txt'
                sh 'zip artifacts.zip app.py requirements.txt'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'artifacts.zip', fingerprint: true
        }
    }
}