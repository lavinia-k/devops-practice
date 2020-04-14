pipeline {
    agent any
    stages {
        stage('Lint HTML') {
            steps {
                sh 'tidy -q -e *.html'
            }
        }
        stage('Upload to AWS') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    s3Upload(bucket:'udacity-devops-engineer-pipelines-jenkins', file: 'index.html')
                }
            }
        }
        stage('Upload EKS CFN to AWS') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    s3Upload(bucket:'devops-practice-resources', file: 'kubernetes-cluster/eks-stack.yaml')
                }
            }
        }
        stage('Validate EKS CFN') {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-static') {
                    cfnValidate(file: 'kubernetes-cluster/cluster-infra.yaml')
                }
            }
        }
        // stage('Deploy Kubernetes Cluster CFN') {
        //     steps {
        //         withAWS(region: 'us-east-1', credentials: 'aws-static') {
        //             cfnUpdate(
        //                 stack: 'kubernetes-cluster', 
        //                 file: 'kubernetes-cluster/cluster-infra.yaml',
        //                 params: 
        //                     ['KeyPairName': 'kubernetes',
        //                      'AvailabilityZones': 'us-east-1a, us-east-1b, us-east-1c',
        //                      'RemoteAccessCIDR': '110.33.24.184/32'])
        //         }
        //     }
        // }
    }

}
