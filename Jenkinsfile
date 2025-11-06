pipeline {
    agent { 
        node {
            label 'golang-docker-agent'
            }
      }
    triggers {
        pollSCM '* * * * *'
    }
    stages {
        stage('Build') {
            steps {
                echo "Building.."
                sh '''
                go mod tidy
                go build .
                '''
            }
        }
        stage('Test') {
            steps {
                echo "Testing.."
                sh '''
                curl localhost:8080
                '''
            }
        }
        stage('Deliver') {
            steps {
                echo 'Deliver....'
                sh '''
                echo "doing delivery stuff.."
                '''
            }
        }
    }
}