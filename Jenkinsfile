pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        sh 'mvn --version'
        echo 'Build'
        echo "PATH - $PATH"
        echo "BUILD_NUMBER - $env.BUILD_NUMBER"
        echo "BUILD_ID - $env.BUILD_ID"
        echo "JOB_NAME - $env.JOB_NAME"
        echo "BUILD_TAG - $env.BUILD_TAG"
        echo "BUILD_URL - $env.BUILD_URL"
        echo "ECR_URL -   $env.ECR_URL"
      }
    }

    stage('Compile') {
      steps {
        sh 'mvn clean compile'
      }
    }

    stage('Test') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Integration Test') {
      steps {
        sh 'mvn failsafe:integration-test failsafe:verify'
      }
    }

    stage('Package') {
      steps {
        sh 'mvn package -DskipTests'
      }
    }

    stage('Build Docker Image') {
      agent {
        docker {
          image 'maven:3.5.2'
          args '-v /var/jenkins_home/workspace/enkin-devops-microservice_master:/opt/maven -w /opt/maven'
          reuseNode true
        }

      }
      steps {
        script {
          sh "docker build  -t intercorp ."
          sh "docker tag intercorp:latest 931914722589.dkr.ecr.us-east-1.amazonaws.com/intercorp:latest"
        }

      }
    }

    stage('Push Docker Image') {
      agent {
        label 'master'
      }
      steps {
        script {
          docker.withRegistry('https://931914722589.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:ecr_deploy') {
            sh "docker push 931914722589.dkr.ecr.us-east-1.amazonaws.com/intercorp:latest"
          }
        }

      }
    }

    stage('Deploy') {
      steps {
        sh "sed -i 's|{{image}}|${docker_repo_uri}:${BUILD_ID}|' taskdef.json"
        sh "aws ecs register-task-definition --execution-role-arn ${exec_role_arn} --cli-input-json file://taskdef.json --region ${region}"
        sh "aws ecs update-service --cluster ${cluster} --service sample-app-service --task-definition ${task_def_arn} --region ${region}"
      }
    }

  }
  tools {
    maven 'M3'
  }
  environment {
    dockerHome = 'mydocker'
    mavenHome = 'M3'
    PATH = "$dockerHome/bin:$mavenHome/bin:$PATH"
    region = 'us-east-1'
    docker_repo_uri = '931914722589.dkr.ecr.us-east-1.amazonaws.com/intercorp'
    task_def_arn = 'arn:aws:ecs:us-east-1:931914722589:task-definition/first-run-task-definition'
    cluster = 'default'
    exec_role_arn = 'arn:aws:iam::931914722589:role/ecsTaskExecutionRole'
  }
}