pipeline {
    agent {
        docker { image 'node:12.2.0' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}