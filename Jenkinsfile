pipeline {
  agent any
  environment {
		dockerHome = tool 'mydocker'
		mavenHome = tool 'M3'
		PATH = "$dockerHome/bin:$mavenHome/bin:$PATH"
	}

   tools {
    maven 'M3'
  }
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
      agent any
      steps {
        script {
          app = docker.build("aldanar1/currency-exchange-devops:${env.BUILD_TAG}")
          app.inside {
            sh 'echo $(curl localhost:8000)'
          }
        }

      }
    }

    stage('Push Docker Image') {
      agent {
        label 'master'
      }
      steps {
        script {
          docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
          }
        }

      }
    }

  }
}
