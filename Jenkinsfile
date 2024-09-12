pipeline {
  agent any

  stages {
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar' // Archiving the artifacts
      }
    }   
    stage('Unit Tests - JUnit and Jacoco') {
      steps {
        sh "mvn test"
      }
      post { 
        always {
          junit 'target/surefire-reports/*.xml'
          script {
            def jacocoReport = new hudson.plugins.jacoco.JacocoPublisher()
            jacocoReport.execPattern = 'target/jacoco.exec'
            jacocoReport.record()
          }
        }
      }
    }   
  }
}
