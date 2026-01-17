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

        stage('Checkout from Git') {
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
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds') {
                        sh '''
                        docker build -t swiggy .
                        docker tag swiggy tathyagat/swiggy:latest
                        docker push tathyagat/swiggy:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                docker rm -f swiggy || true
                docker run -d \
                  --name swiggy \
                  -p 3000:3000 \
                  tathyagat/swiggy:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Swiggy app deployed.'
        }
        failure {
            echo 'Pipeline failed. Check Jenkins logs.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}

