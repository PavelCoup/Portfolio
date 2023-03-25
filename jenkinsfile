pipeline {
    agent any
    environment {
        gitUrl      = 'https://github.com/PavelCoup/IT_Bootcamp.git'
        imageName   = 'it-bootcamp'
        hubUsername = 'pavelcoup'
        hubToken    = 'dckr_pat_6kHqegbiVZwbSQ25P3SQON9yGZ4'
        kubectl     = 'microk8s kubectl'
        emailTo     = 'test@test.com'
        port        = '88'
    }
    stages {
        stage('Clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: "${gitUrl}"]]])
            }
        }
        stage('Validate Dockerfile') {
            steps {
                sh 'docker run --rm -i hadolint/hadolint hadolint --ignore DL3003 --ignore DL3007 - < Dockerfile'
            }
        }
        stage('Build Docker image') {
            steps {
                sh "docker build -t ${imageName}:latest ."
            }
        }
        stage('Test Docker image') {
            steps {
                sh "docker run -d --name ${imageName} -p ${port}:8888 ${imageName}:latest"
                sh 'sleep 5'
                script {
                    def response = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:${port}", returnStdout: true).trim()
                    if (response != '200') {
                        error("The page is not available. HTTP status code: ${response}.")
                    }
                }    
            }
        }    
        stage('Push Docker image') {
            steps {
                // withCredentials([usernamePassword(credentialsId: '<credentials-id>', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) { // Получение учетных данных для реестра образов
                sh "docker login -u ${hubUsername} -p ${hubToken}"
                sh "docker tag ${imageName} ${hubUsername}/${imageName}:latest"
                sh "docker push ${hubUsername}/${imageName}:latest"
            }
        }
        stage('Deploy to pre-production environment') {
            steps {
                sh "${kubectl} create namespace pre-production || true"
                sh "${kubectl} delete deployment ${imageName} -n pre-production || true"
                sh "${kubectl} create deployment ${imageName} --image ${hubUsername}/${imageName}:latest -n pre-production"
                //sh "${kubectl} apply -f pre-production.yaml"
            }
        }
        stage('Test pre-production deployment') {
            steps {
                script {
                    def str = sh(script: "${kubectl} rollout status deployment ${imageName} -n pre-production --timeout=30s", returnStdout: true).trim()
                    if (!str.contains("successfully")) {
                        error("${str}")
                    }
                }
                input 'Deployment was successful. Deploy to production?'
            }
        }
        stage('Deploy to production environment') {
            steps {
                sh "${kubectl} create namespace production || true"
                sh "${kubectl} delete deployment ${imageName} -n production || true"
                sh "${kubectl} create deployment ${imageName} --image ${hubUsername}/${imageName}:latest -n production"
            }
        }
    }

    post { 
        always { 
            sh "docker rm -f ${imageName}"
            sh "${kubectl} delete deployment ${imageName} -n pre-production || true"
            //sh "${kubectl} delete -f pre-production.yaml || true"
        }
        success {
            script {
                try {
                    emailext body: "${env.BUILD_URL} has result success", 
                        to: "${emailTo}", 
                        subject: "Build ${currentBuild.fullDisplayName} success"
                }
                catch (err) {
                        echo "Failed: ${err}"
                }
            }
        }
        failure {
            script {
                try {
                    emailext body: "${env.BUILD_URL} has result fail", 
                        to: "${emailTo}", 
                        subject: "Build ${currentBuild.fullDisplayName} fail"
                }
                catch (err) {
                        echo "Failed: ${err}"
                }
            }
        }
    }
}
