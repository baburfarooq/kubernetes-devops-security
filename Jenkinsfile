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
      
    }

    stage('Mutation Tests - PIT') {
      steps {
        sh 'mvn org.pitest:pitest-maven:mutationCoverage'
      } 
}

    stage('SonarQube SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-adppication -Dsonar.host.url=http://devsecops-demo.centralus.cloudapp.azure.com:9000"
        }
        timeout(time: 2, unit: 'MINUTES'){
          script {
            waitForQualityGate abortPipeline: true
                    }
                }
            }
    }

    stage('Vulnerability Scan - Docker') {
      steps {
      parallel (
        "Dependency Scan":{
            sh "mvn dependency-check:check"
        },
          "Trivy Scan" :{
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest" : {
            sh "$ docker run --rm -v $(pwd):/project openpolicyagent/conftest --policy opa-docker-security.rego Dockerfile"
          }
      )
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: 'docker-hub', url: '']) {
        sh 'printenv'
        sh 'sudo docker build -t baburfarooq82/numeric-app:"$GIT_COMMIT" .'
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
  post { 
        always {
          junit 'target/surefire-reports/*.xml'
          // Archive the JaCoCo report files
          jacoco execPattern: 'target/jacoco.exec'
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

        }
      }
}

