pipeline {
    agent any
    stages {
        stage('Lint HTML') {
            steps {
                sh 'tidy -q -e *.html'
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

        stage('Deploy app') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    sh 'aws eks --region us-east-1 update-kubeconfig --name EKS-q0RORZurvK2e'
                }
            }
        }

    }

}
