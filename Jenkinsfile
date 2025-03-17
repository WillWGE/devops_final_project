pipeline {
    agent any

    environment {
        // Google Cloud project and credentials
        GCP_PROJECT = 'project-production'
        GCR_REGISTRY = "asia-southeast2-docker.pkg.dev/${GCP_PROJECT}"
        IMAGE_NAME = 'simple-app/nodejs-app'
        IMAGE_TAG = "${env.BUILD_ID}"
        FULL_IMAGE_NAME = "${GCR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

        GKE_CLUSTER_NAME = "cluster-1"
        GKE_ZONE = "asia-southeast2-b"  // Set the GKE zone where your cluster is hosted

        

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://gitlab.com/hakimrizki/jenkins-demo.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${FULL_IMAGE_NAME} ."
                }
            }
        }

        stage('Push to GCR') {
            steps {
                script {
                    sh "docker push ${FULL_IMAGE_NAME}"
                }
            }
        }

        stage('Get KubeConfig') {
            steps {
                script {
                    sh '''
                        export PATH=$HOME/google-cloud-sdk/bin:$PATH
                        echo "New PATH: $PATH"
                        which gcloud || echo "gcloud not found"
                        gcloud --version || echo "gcloud command failed"
                        gcloud container clusters get-credentials aiflow-cluster --zone asia-southeast2-a --project inspiring-being-284903
                    '''
                }
            }
        }

        stage('Set KubeContext') {
            steps {
                script {
                    sh """
                        kubectl config use-context gke_${GCP_PROJECT}_${GKE_ZONE}_${GKE_CLUSTER_NAME}
                    """
                }
            }
        }

        stage('Deploy with New Image') {
            steps {
                script {
                    def exitCode = sh(
                        script: '''
                        export PATH=$HOME/google-cloud-sdk/bin:$PATH
                        echo "New PATH: $PATH"
                        which gcloud || echo "gcloud not found"
                        gcloud --version || echo "gcloud command failed"
                        
                        gcloud components install gke-gcloud-auth-plugin || true

                        kubectl set image deployment/nodejs-app app=${FULL_IMAGE_NAME} migrate=${FULL_IMAGE_NAME}
                        ''',
                        returnStatus: true
                    )

                    if (exitCode != 0){
                        error("Deployment failed with exit code: ${exitCode}")
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${FULL_IMAGE_NAME} || true"
        }
        success {
            script {
                def message = "✅ **Deployment Successful**: ${currentBuild.fullDisplayName} has been deployed! 🎉"
                sendDiscordNotification(message)
            }
        }
        failure {
            script {
                def message = "❌ **Deployment Failed**: ${currentBuild.fullDisplayName} encountered an error. ⚠️"
                sendDiscordNotification(message)
            }
        }
    }
}

