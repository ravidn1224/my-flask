pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jenkins-agent-custom' // ← שימי את שם התמונה שלך כאן
        DOCKERHUB_USER = 'ravidocker285'    // ← שם המשתמש שלך ב-DockerHub
        REMOTE_HOST = 'ubuntu@172.31.28.95' // ← החליפי ב-IP הציבורי של App Server
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_USER}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to App Server') {
            steps {
                sshagent(['app-server-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_HOST} '
                            docker pull ${DOCKERHUB_USER}/${IMAGE_NAME}:latest &&
                            docker stop flask-app || true &&
                            docker rm flask-app || true &&
                            docker run -d --name flask-app -p 5000:5000 ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        '
                    """
                }
            }
        }
    }
}
