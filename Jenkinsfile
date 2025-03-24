pipeline {
    agent any

    environment {
        // Google Cloud project and credentials
        GCP_PROJECT = 'project-production'
        DOCKER_IMAGE= 'williamwg/nodejs-app'
        IMAGE_TAG = "latest"
        GKE_CLUSTER_NAME = "cluster-1"
        GKE_ZONE = "asia-southeast2-b"  // Set the GKE zone where your cluster is hosted
        DOCKERHUB_CREDENTIALS=credentials('dockerhubpwd')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/WillWGE/devops_final_project']])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        stage('Log in DockerHub') {
            steps {
                    sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
        }
         }

        stage('Push Docker Image') {
            steps {
                    sh "docker push $DOCKER_IMAGE:$IMAGE_TAG"
             }
            }

        stage('Authenticate with GCP') {
            steps {
                script {
                    // Use the service account stored in Jenkins credentials
                    withCredentials([file(credentialsId: 'service_account', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                            # Authenticate with GCP using the service account
                            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                            
                            # Set the project
                            gcloud config set project project-production-449715
                            
                            # Verify authentication
                            gcloud auth list

                            # get kubernetes configuration
                            gcloud container clusters get-credentials cluster-1 --zone asia-southeast2-b --project project-production-449715


                        '''
                    }
                }
            }
        }

        // stage('Set KubeContext') {
        //     steps {
        //         script {
        //             sh """
        //                 kubectl config use-context gke_${GCP_PROJECT}_${GKE_ZONE}_${GKE_CLUSTER_NAME}
        //             """
        //         }
        //     }
        // }

        stage('Deploy to Kubernetes Cluster'){
            steps{
                script{
                    '''
                        kubectl set image deployment/nodejs-app app='williamwg/nodejs-app:latest' --namespace=default
                    '''
                }
            }
        }
    }
}

    // post {
    //     always {
    //         sh "docker rmi ${FULL_IMAGE_NAME} || true"
    //     }
    //     success {
    //         script {
    //             def message = "✅ **Deployment Successful**: ${currentBuild.fullDisplayName} has been deployed! 🎉"
    //             sendDiscordNotification(message)
    //         }
    //     }
    //     failure {
    //         script {
    //             def message = "❌ **Deployment Failed**: ${currentBuild.fullDisplayName} encountered an error. ⚠️"
    //             sendDiscordNotification(message)
    //         }
    //     }

