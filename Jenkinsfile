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
                git branch: 'main',
                    url: 'https://github.com/tathyagatBytelab/swiggy-devops.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                      -Dsonar.projectKey=Swiggy \
                      -Dsonar.projectName=Swiggy \
                      -Dsonar.sources=.
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
                sh 'docker build -t tathyagat/swiggy:latest .'
            }
        }

        stage('Docker Push') {
            steps {
                sh 'docker push tathyagat/swiggy:latest'
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

