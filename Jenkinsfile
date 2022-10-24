  pipeline {
  agent any
     environment {
      accountID = ""
    }
  stages {
    stage('Checkout') {
        steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/awsdevopsssp/ecr-ecs-cicd.git']]])
            sh '''cd $WORKSPACE; ls -ltr'''
        }
    }
    stage('BUILD'){
        steps {
            sh '''        
            cd $WORKSPACE
            docker build -t  $accountID.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER .
            docker tag $accountID.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER $accountID.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:latest
            '''            
        }
    }
    stage('ECR Login & Push'){
        steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'azmsspiam', passwordVariable: 'AWSPASS', usernameVariable: 'AWSUSER')]) {
                docker.image('amazon/aws-cli:latest').withRun("--entrypoint=bash") {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWSUSER
                    export AWS_SECRET_ACCESS_KEY=$AWSPASS
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $accountID.dkr.ecr.us-east-1.amazonaws.com
        
                    docker push $accountID.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER
                    docker push $accountID.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:latest
                    '''
                } 
            }
        }
  }
    }
    stage('Deploy to ECS'){
        steps {
            script {
                withCredentials([usernamePassword(credentialsId: 'azmsspiam', passwordVariable: 'AWSPASS', usernameVariable: 'AWSUSER')]) {
                    docker.image('amazon/aws-cli:latest').withRun("--entrypoint=bash") {
                    sh'''
                        
                        export AWS_ACCESS_KEY_ID=$AWSUSER
                        export AWS_SECRET_ACCESS_KEY=$AWSPASS
                        aws s3 ls
                        
                        TASK_NAME="ssp-task"
                        SERVICE_NAME="ssp-node-service"
                        CLUSTER_NAME="ssp-cluster"
                        REGION="us-east-1"

                        aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_NAME --region $REGION --force-new-deployment

                    '''
                     }
                }
            }  
        }
    }
  }
}
