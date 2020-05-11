pipeline {
    agent any
    environment {
        HOME = '.'
        imageTag = 'todo:v1'
        imageArtifactLocation = 'image'
        imagePath = './image/todoImage.tar'
    }
    stages {
        stage('Test:unit') {
            agent {
                docker { image 'node:12.2.0' }
            }
            steps {
                sh 'yarn install'
                sh 'yarn run test:unit'
            }
            
        }
        stage('Test:e2e') {
            agent {
                docker {
                    image 'cypress/base:14.0.0' 
                }
            }      
            steps {
                sh 'yarn install'
                sh './node_modules/.bin/cypress install'
                sh 'yarn test:e2e'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t ${imageTag} .'
                sh 'mkdir -p ${imageArtifactLocation} && rm -rf ${imagePath}'
                sh 'docker save -o ${imagePath} ${imageTag}'
                sh 'sudo chmod -R 777 ${imagePath}'
            }
            post {
                 always {
                    archiveArtifacts artifacts:'image/todoImage.tar', fingerprint: true, onlyIfSuccessful: true
                 }
            }
        }
        stage('Wait for user approve') {
            steps {
                input "Deploy?"
            }
        }
        stage('Push to registry') {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
				    sh '''
                        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
					    docker push $DOCKER_USERNAME/'${imageTag}'
				    '''
                }
            }
        }
        stage('Config kubectl cluster') {
			steps {
				withAWS(region:'us-east-1', credentials:'aws-cre') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-1:134672071065:cluster/zcluster
					'''
				}
			}
		}

        stage('Deploy on EKS ') {
			steps {
				withAWS(region:'us-east-1', credentials:'aws-cre') {
					sh '''
						kubectl apply -f ./k8s/todo-deployment.yml
                        kubectl apply -f ./k8s/todo-service.yml
					'''
				}
			}
		}

    }
   
}