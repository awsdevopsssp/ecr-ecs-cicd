node() {

environment {
    TASK_NAME="first-run-task-definition"
    SERVICE_NAME="nginx-service"
    CLUSTER_NAME="azmsspecs"
    REGION="us-east-1"
}

stage('checkout') {
        
        // checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'jenkinsnew', url: 'https://github.com/azeemmd150/node-ecs-demo.git']]])
        checkout([$class: 'GitSCM', branches: [[name: '*/develop']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/awsdevopsssp/nov-devops-1.git']]])
    }
  
    
withCredentials([usernamePassword(credentialsId: 'azmsspiam', passwordVariable: 'AWSPASS', usernameVariable: 'AWSUSER')]) {
    docker.image('amazon/aws-cli:latest').withRun("--entrypoint=bash") {
        stage('Build') {
            sh """
            docker build -t 435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER .
            docker tag 435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER 435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:latest
            """
        }
        stage('Push to ECR') {
            sh """
            export AWS_ACCESS_KEY_ID=$AWSUSER
            export AWS_SECRET_ACCESS_KEY=$AWSPASS
            aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 435429793199.dkr.ecr.us-east-1.amazonaws.com
   
            docker push 435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER
            docker push 435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:latest

            """
        }
        stage('Deploy to ECS'){
            sh """
            export AWS_ACCESS_KEY_ID=$AWSUSER
            export AWS_SECRET_ACCESS_KEY=$AWSPASS
            chmod +x deploy.sh
            ./deploy.sh ${REGION} ${TASK_NAME} ${SERVICE_NAME}

            """
        }
}
}

}