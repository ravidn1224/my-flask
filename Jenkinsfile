pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ravidocker285/flask-app:latest'
        APP_HOST = 'ubuntu@<EC2-PUBLIC-IP>'
        SSH_CRED_ID = 'app-server-key'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [SSH_CRED_ID]) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $APP_HOST '
                        docker pull $DOCKER_IMAGE &&
                        docker rm -f flask-app || true &&
                        docker run -d --name flask-app -p 5000:5000 $DOCKER_IMAGE
                    '
                    '''
                }
            }
        }
    }
}
