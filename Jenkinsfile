pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'

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
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    }

    stage('Mutation Tests - PIT') {
      steps {
        sh 'mvn org.pitest:pitest-maven:mutationCoverage'
      } 
      post {
        always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
    }
}

    stage('SonarQube SAST') {
      steps {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://devsecops-demo.centralus.cloudapp.azure.com:9000 -Dsonar.login=sqb_660459a9a6ec19110fefcf6c05f066da6a56f6f6"
                    }
            }




    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: 'docker-hub', url: '']) {
        sh 'printenv'
        sh 'docker build -t baburfarooq82/numeric-app:"$GIT_COMMIT" .'
        sh 'docker push baburfarooq82/numeric-app:"$GIT_COMMIT"'
        }
       }
     }
    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          // Ensure image tag substitution is correct
          sh "sed -i 's#replace#baburfarooq82/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          
          // Apply the Kubernetes configuration
          sh "kubectl apply -f k8s_deployment_service.yaml"
          
        }
      }


    }
  }
}

