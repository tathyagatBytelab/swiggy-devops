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

        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs . > trivy-fs-report.txt'
                archiveArtifacts artifacts: 'trivy-fs-report.txt', allowEmptyArchive: true
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-creds') {
                        sh '''
                        docker build -t swiggy .
                        docker tag swiggy kastrov/swiggy:latest
                        docker push kastrov/swiggy:latest
                        '''
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image kastrov/swiggy:latest > trivy-image-report.txt'
                archiveArtifacts artifacts: 'trivy-image-report.txt', allowEmptyArchive: true
            }
        }

        stage('Deploy to Container') {
            steps {
                sh '''
                docker rm -f swiggy || true
                docker run -d --name swiggy -p 3000:3000 kastrov/swiggy:latest
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

