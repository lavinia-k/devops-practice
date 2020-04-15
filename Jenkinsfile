pipeline {
    agent any
    stages {
        stage('Lint Python') {
            steps {
                sh 'python3 -m venv ~/.devops'
                sh '. ~/.devops/bin/activate && pip install -r flask-app/requirements.txt'
                sh '. ~/.devops/bin/activate && pylint --disable=R,C,W1203 flask-app/app.py'
            }
        }

        stage('Validate CFN templates') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    cfnValidate(file: 'kubernetes-cluster/cluster-infra.yaml')
                    cfnValidate(file: 'kubernetes-cluster/eks-stack.yaml')
                }
            }
        }

        stage('Build app Docker image') {
            steps {
                script {
                    app = docker.build("laviniak/practice-flask-app", "-f ./flask-app/Dockerfile .")
                }
            }
        }

        stage('Push app Docker image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }

        stage('Upload nested template CFN to S3') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    s3Upload(bucket:'devops-practice-resources', file: 'kubernetes-cluster/eks-stack.yaml')
                }
            }
        }

        stage('Deploy Kubernetes Cluster CFN') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    cfnUpdate(
                        stack: 'kubernetes-cluster', 
                        file: 'kubernetes-cluster/cluster-infra.yaml',
                        params: 
                            ['KeyPairName': 'kubernetes',
                             'AvailabilityZones': 'us-east-1a, us-east-1b, us-east-1c',
                             'RemoteAccessCIDR': '110.33.24.184/32'])
                }
            }
        }

        stage ('Deploy app to Kubernetes cluster with Ansible') {
           steps {
               script{
                   sh "ansible-playbook  playbook.yml --extra-vars \"image_tag=${env.BUILD_NUMBER}\""
               }
           }
       }

    }

}
