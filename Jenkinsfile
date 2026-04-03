pipeline {
    agent any

    environment {
        IMAGE_NAME = "rethanya/python-cicd-app"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Build Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(
                  credentialsId: 'dockerhub-creds',
                  usernameVariable: 'DOCKER_USER',
                  passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                  sed 's/{{TAG}}/${IMAGE_TAG}/g' k8s/deployment.yaml | kubectl apply -f -
                  kubectl apply -f k8s/service.yaml
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl rollout status deployment/python-cicd-app --timeout=60s"
            }
        }
    }

    post {
        failure {
            sh "kubectl rollout undo deployment/python-cicd-app"
        }
    }
}
