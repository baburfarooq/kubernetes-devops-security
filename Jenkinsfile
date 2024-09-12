pipeline {
  agent any

  stages {
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar' // Fixed archiving artifacts syntax
      }
    }   
    stage('Unit Tests - JUnit and JaCoCo') {
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
