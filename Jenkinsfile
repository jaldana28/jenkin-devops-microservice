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
          sh "docker build  -t $env.ECR_URL/intercorp/devops-microservice:latest ."
        }

      }
    }

    stage('Push Docker Image') {
      agent {
        label 'master'
      }
      steps {
        script {
          docker.withRegistry('https://"$env.ECR_URL".us-east-1.amazonaws.com', 'ecr:us-east-1:ecr_deploy') {
                docker.image("devops-microservice").push()
          }
        }

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
  }
}
