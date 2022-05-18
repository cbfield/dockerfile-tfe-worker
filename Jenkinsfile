pipeline {
  agent {
    kubernetes {
      yaml '''
        kind: Pod
        spec:
          containers:
          - name: al2
            image: amazonlinux:2
            imagePullPolicy: Always
            command: ['cat']
            tty: true
            env: 
            - name: DOCKER_HOST 
              value: tcp://localhost:2375
          - name: dind-daemon
            image: docker:20.10.6-dind
            securityContext:
              privileged: true
            volumeMounts:
              - name: dind-storage
                mountPath: /var/lib/docker
            env:
            - name: DOCKER_TLS_CERTDIR
              value: ""
          volumes:
            - name: dind-storage
              emptyDir: {}
          restartPolicy: Never
          serviceAccount: jenkins-agent
      '''
    }
  }
  environment {
    ECR = "000111222333.dkr.ecr.us-east-1.amazonaws.com/terraform-enterprise-worker"
  }
  stages {
    stage('Docker Setup') {
      steps {
        container('al2') {
          sh '''
            amazon-linux-extras install docker
            yum install -y amazon-ecr-credential-helper

            [[ -d /root/.docker ]] || mkdir /root/.docker
            echo '{"credsStore":"ecr-login"}' > /root/.docker/config.json
          '''
        }
      }
    }
    stage('Docker Build') {
      steps {
        container('al2') {
          sh """
            docker build -t ${ECR}:latest -t ${ECR}:${env.BRANCH_NAME} .
          """
        }
      }
    }
    stage('Docker Push') {
      steps {
        container('al2') {
          sh """
            docker image push --all-tags ${ECR}
          """
        }
      }
    }
  }
}
