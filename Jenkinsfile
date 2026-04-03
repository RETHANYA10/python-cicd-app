pipeline {
    agent any

    environment {
        IMAGE_NAME = "rethanya/python-cicd-app"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
    }

    stages {

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                sh """
                  docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                """
            }
        }

        stage("Push Docker Image") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "dockerhub-creds",
                    usernameVariable: "DOCKER_USER",
                    passwordVariable: "DOCKER_PASS"
                )]) {
                    sh """
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${IMAGE_NAME}:${IMAGE_TAG}
                      docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                sh """
                  sed s/{{TAG}}//g k8s/deployment.yaml | kubectl apply -f -
                  kubectl apply -f k8s/service.yaml

                  kubectl annotate deployment python-app                     kubernetes.io/change-cause="Deploy ${IMAGE_NAME}:${IMAGE_TAG}"                     --overwrite

                  kubectl rollout status deployment/python-app --timeout=120s
                """
            }
        }
    }

    post {
        failure {
            echo "Deployment failed – rolling back python-app"
            sh """
              kubectl rollout undo deployment/python-app
              kubectl rollout status deployment/python-app
            """
        }

        success {
            echo "Deployment ${IMAGE_NAME}:${IMAGE_TAG} succeeded"
        }
    }
}
