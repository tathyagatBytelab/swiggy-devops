pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node20'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/KastroVKiran/DevOps-Project-Swiggy.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                      -Dsonar.projectName=Swiggy \
                      -Dsonar.projectKey=Swiggy
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t swiggy .'
            }
        }

        stage('Docker Push') {
            steps {
                withDockerRegistry(credentialsId: 'docker-creds', toolName: 'docker') {
                    sh '''
                    docker tag swiggy tathyagat/swiggy:latest
                    docker push tathyagat/swiggy:latest
                    '''
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image tathyagat/swiggy:latest'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker rm -f swiggy || true
                docker run -d --name swiggy -p 3000:3000 tathyagat/swiggy:latest
                '''
            }
        }
    }
}

