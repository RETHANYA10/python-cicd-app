pipeline {
    agent any

    environment {
        IMAGE_NAME = "python-cicd-app"
        DOCKERHUB_REPO = "rethanya/python-cicd-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

       stage('Run Tests') {
    steps {
        sh '''
            set -e
            export PYTHONPATH=$(pwd)

            python3 -m venv venv
            . venv/bin/activate

            pip install --upgrade pip
            pip install -r requirements.txt

            pytest
        '''
    }
}

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag $IMAGE_NAME:latest $DOCKERHUB_REPO:latest
                        docker push $DOCKERHUB_REPO:latest
                    '''
                }
            }
        }
    }
}
