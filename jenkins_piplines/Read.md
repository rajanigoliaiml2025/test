# Deployment scripts in Groovy are most frequently used within Jenkins Pipelines to orchestrate releases across different environments. Below are specific templates for Kubernetes, AWS, and Tomcat.

1. Kubernetes (EKS/Generic)
This script uses the Kubernetes CLI (kubectl) to apply a configuration. It assumes you have a kubeconfig file stored in Jenkins credentials.


pipeline {
    agent any
    environment {
        // ID of the 'Secret file' credential containing your kubeconfig
        KUBECONFIG = credentials('genai-aks-kube-config') 
    }
    stages {
        stage('Deploy to K8s') {
            steps {
                script {
                    // Points kubectl to the credential file
                    sh "kubectl --kubeconfig=${KUBECONFIG} apply -f deployment.yaml"
                    sh "kubectl --kubeconfig=${KUBECONFIG} rollout status deployment/genai-payment-scu-dev-0001"
                }
            }
        }
    }
}
