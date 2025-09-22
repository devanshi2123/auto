pipeline {
    agent any

    environment {
        TF_DIR = "infra"
        DOCKER_REPO = "devanshi2123/flask-app"
        DOCKER_CREDS_ID = "dockerhub-creds"
        AWS_CREDS_ID = "aws-creds"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Windows-safe Git short SHA
                    env.SHORT_SHA = bat(script: 'git rev-parse --short HEAD', returnStdout: true).trim().tokenize('\r\n')[-1]
                    env.IMAGE_TAG = "${BUILD_NUMBER}-${SHORT_SHA}"
                }
                echo "✅ Image tag will be: ${IMAGE_TAG}"
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                   docker build -t %DOCKER_REPO%:%IMAGE_TAG% .
                """
            }
        }

        stage('Login & Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS_ID}", usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    bat """
                      echo Logging into DockerHub...
                      docker login -u %DOCKERHUB_USER% -p %DOCKERHUB_PASS%
                      docker tag %DOCKER_REPO%:%IMAGE_TAG% %DOCKER_REPO%:latest
                      docker push %DOCKER_REPO%:%IMAGE_TAG%
                      docker push %DOCKER_REPO%:latest
                    """
                }
            }
        }

        stage('Terraform Init/Plan/Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${AWS_CREDS_ID}", usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TF_DIR}") {
                        bat """
                          echo Setting AWS credentials...
                          set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                          set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                          
                          echo Initializing Terraform...
                          terraform init -input=false
                          
                          echo Planning Terraform deployment...
                          terraform plan -var="docker_image=%DOCKER_REPO%:%IMAGE_TAG%" -var="key_name=project2_docker" -out=tfplan
                          
                          echo Applying Terraform deployment...
                          terraform apply -input=false -auto-approve tfplan
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully: %DOCKER_REPO%:%IMAGE_TAG% deployed."
        }
        failure {
            echo "❌ Pipeline failed. Check console output for errors."
        }
        always {
            bat """
              echo Cleaning up Docker image...
              docker image rm %DOCKER_REPO%:%IMAGE_TAG% || echo "Image not found, skipping removal"
            """
        }
    }
}
