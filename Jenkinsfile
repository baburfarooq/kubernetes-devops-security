pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true" //clean up
        archive 'target/*.jar'

      }
    }   
  }
}
