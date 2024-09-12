pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                // Your build steps here
                sh 'mvn clean install'
            }
        }
        stage('Test') {
            steps {
                // Running tests
                sh 'mvn test'
            }
        }
        stage('Code Coverage') {
            steps {
                // Using Jacoco to collect code coverage
                jacoco(execPattern: '**/target/*.exec', classPattern: '**/target/classes', sourcePattern: '**/src/main/java', exclusionPattern: '**/target/test-classes')
            }
        }
    }
    post {
        always {
            // Publish Jacoco report
            jacoco()
        }
    }
}
