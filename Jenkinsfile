pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar' // Archiving the artifacts
      }
    }   
    stage('Unit Tests') {
      steps {
        sh "mvn test"
      }
    }   
  }
}
