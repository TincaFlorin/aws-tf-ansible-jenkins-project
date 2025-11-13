pipeline {
    agent { 
        docker {
            image 'tincadocker/jenkins_agent'
            args '--volume /var/run/docker.sock:/var/run/docker.sock'
        }
      }
    environment {
        VISITS_IMAGE = 'tincaflorin/visits:latest'
        VISITS_PORT = '9000'
        DOCKER_USERNAME = credentials('DOCKER_HUB_USER')
        DOCKER_PASSWORD = credentials('DOCKER_HUB_PASS')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/TincaFlorin/visits.git'
            }
        }
        stage('Check wd') {
            steps {
                echo "Checking working directory..."
                sh 'pwd && ls -la'
            }
        }
        stage('Build') {
            steps {
                echo "Building.."
                sh '''
                go mod tidy
                go build -o visits .
                '''
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Deliver....'
                sh '''
                ./visits &
                curl --retry 5 --retry-delay 4 --retry-max-time 40 http://localhost:${VISITS_PORT}
                '''
            }
        }
        stage('Package') {
            steps {
                echo 'Packaging'
                sh '''
                docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                docker build -t ${VISITS_IMAGE} ./
                docker push ${VISITS_IMAGE}
                '''
            }
        }
        stage('Check Existing Container') {
            steps {
                script { 
                    echo "Checking if container is running on port ${VISITS_PORT}..."
                    // Check if a container is using the port
                    def existing = sh(
                        script: "docker ps -qa --filter name=visits",
                        returnStdout: true
                    ).trim()

                    if (existing) {
                        echo "Container running on port ${VISITS_PORT} (ID: ${existing}). Stopping and removing it..."
                        sh "docker stop ${existing} && docker rm ${existing}"
                    } else {
                        echo "No container running on port ${VISITS_PORT}."
                    }
                }
            }
        }
        stage('Deploy New Container') {
            steps {
                echo "Starting new container..."
                sh '''
                    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                    docker run -d \
                        --name visits \
                        -p ${VISITS_PORT}:${VISITS_PORT} \
                        ${VISITS_IMAGE}
                '''
            }
        }
    }
}