def namespace = "hasura-namespace"
def appName = 'hasura-example'


pipeline {
  agent any
  environment {
    DOCKER_IMAGE = "hasura/graphql-engine"
    DOCKER_TAG = "v2.40.2"
    TAG = "${env.GIT_COMMIT.take(8)}"
    PROJECT_NAME = "${appName}"
    NAMESPACE = "${namespace}"
  }
  
  stages {

    stage('Build Development') {
      environment {
        DOCKER_REGISTRY_URL = 'registry.hub.docker.com'
        DOCKER_CREDENTIALS = credentials('docker_registry')
        DOCKER_REPO_CREDENTIALS = credentials('image_repo_bri')
      }
      when {
        branch 'development'
      }
      steps {
        sh 'docker login ${DOCKER_REGISTRY_URL} -u $DOCKER_CREDENTIALS_USR -p ${DOCKER_CREDENTIALS_PSW}'
        sh 'docker build -t ${DOCKER_REGISTRY_URL}/${PROJECT_NAME}:${TAG} .'
        sh 'docker push ${DOCKER_REGISTRY_URL}/${PROJECT_NAME}:${TAG}'
        sh 'docker rmi ${DOCKER_REGISTRY_URL}/${PROJECT_NAME}:${TAG}'
      }
    }

    stage('Deploy Development') {
      environment {
        DOCKER_REGISTRY_URL = 'registry.hub.docker.com'
      }
      when {
        branch 'development'
      }
      steps {
        sh """
              helm upgrade ${PROJECT_NAME} ./helm/${PROJECT_NAME} \
                --set-string image.repository=${DOCKER_REGISTRY_URL}/${PROJECT_NAME},image.tag=${TAG} \
                -f helm/${PROJECT_NAME}/values.development.yaml --debug --install --namespace ${NAMESPACE}
            """
      }
    }
    stage('Apply Metadata Development') {
      environment {
        ENDPOINT = 'http://api.customerhub.dev.bri.co.id/api/v1/hasura-chm-schema'
        ADMIN_SECRET = credentials('hasura_chm_admin_secret')
      }
      when {
        branch 'development'
      }
      steps { 
        script {
          def maxRetries = 30  
          def statusCode
          def responseBody

          for (int i = 0; i < maxRetries; i++) {
            def response = sh(script: "curl -s -w '%{http_code}' ${ENDPOINT}/healthz?strict=false", returnStdout: true).trim()

            statusCode = response[-3..-1] 
            responseBody = response[0..-4] 

            echo "Response Body: ${responseBody}"
            echo "Status Code: ${statusCode}"

            if (statusCode == "200") {
              echo "Health check passed with status code: ${statusCode}. Proceeding with metadata apply."
              sh """
                hasura metadata apply --endpoint ${ENDPOINT} --admin-secret ${ADMIN_SECRET} --skip-update-check
              """
              break
            } else {
              echo "Health check failed with status code: ${statusCode}. Retrying..."
            }
            sleep(1)
          }

          if (statusCode != "200") {
            error("Health check failed after ${maxRetries} retries.")
          }
        }
      }
    }
  }
}
