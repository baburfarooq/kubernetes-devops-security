pipeline {
  agent any

  stages {
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar'
      }
    }   
    stage('Unit Tests - JUnit and JaCoCo') {
      steps {
        sh "mvn test"
      }
      post { 
        always {
          junit 'target/surefire-reports/*.xml'
          // Archive the JaCoCo report files
          archiveArtifacts 'target/site/jacoco/*.html'
        }
      }
    }   
  }
}
