pipeline {
    agent any
    tools {
        terraform 'terraform-tool'
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }
    stages {
        stage('Checkout Repositories') {
            steps {
                script {
                    dir('kafka_dynamic') {
                        git branch: 'main', credentialsId: 'git-credential', url: 'https://github.com/himanshu085/kafka_dynamic.git'
                    }
                    dir('roles_kafka_dynamic') {
                        git branch: 'main', credentialsId: 'git-credential', url: 'https://github.com/himanshu085/roles_kafka_dynamic.git'
                    }
                }
                sh 'ls -l kafka_dynamic roles_kafka_dynamic'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('kafka_dynamic/terraformaws5') {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh 'terraform init -migrate-state'
                    }
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('kafka_dynamic/terraformaws5') {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh 'terraform plan'
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    def proceed = input(
                        message: 'Do you want to apply the Terraform changes?',
                        parameters: [choice(name: 'CONFIRM', choices: ['Yes', 'No'], description: 'Select Yes to proceed or No to abort')]
                    )
                    if (proceed == 'Yes') {
                        dir('kafka_dynamic/terraformaws5') {
                            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                                sh 'terraform apply -auto-approve'
                            }
                        }
                    } else {
                        error("Terraform Apply aborted by user.")
                    }
                }
            }
        }
        stage('Run Ansible Playbook Before Destroy') {
            steps {
                dir('roles_kafka_dynamic') {
                    sh 'ls -l kafka-zookeeper/tests'  // Debugging: Ensure playbook exists
                    sh 'test -f aws_ec2.yaml || (echo "aws_ec2.yaml not found!" && exit 1)'
                    sh 'test -f kafka-zookeeper/tests/test.yaml || (echo "test.yaml not found!" && exit 1)'
                    sh 'ansible-playbook -i aws_ec2.yaml kafka-zookeeper/tests/test.yaml --private-key /var/lib/jenkins/workspace/vmkey.pem'
                }
            }
        }
        stage('Terraform Destroy') {
            steps {
                script {
                    def proceed = input(
                        message: 'Do you want to destroy the Terraform infrastructure?',
                        parameters: [choice(name: 'CONFIRM', choices: ['Yes', 'No'], description: 'Select Yes to proceed or No to abort')]
                    )
                    if (proceed == 'Yes') {
                        dir('kafka_dynamic/terraformaws5') {
                            catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    } else {
                        error("Terraform Destroy aborted by user.")
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Cleaning up workspace"
            deleteDir() // Cleans up workspace
        }
        success {
            emailext(
                subject: "✅ Jenkins Build SUCCESS: ${env.JOB_NAME}",
                mimeType: 'text/html',
                body: """
                <h3 style="color: green;">Jenkins Build Successful 🎉</h3>
                <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Status:</strong> ✅ <b>SUCCESS</b></p>
                <p>View details: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider'], [$class: 'DevelopersRecipientProvider']],
                to: 'himanshuparashar085@gmail.com'
            )
        }
        failure {
            emailext(
                subject: "❌ Jenkins Build FAILED: ${env.JOB_NAME}",
                mimeType: 'text/html',
                body: """
                <h3 style="color: red;">Jenkins Build Failed 🚨</h3>
                <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Status:</strong> ❌ <b>FAILURE</b></p>
                <p>View details: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider'], [$class: 'DevelopersRecipientProvider']],
                to: 'himanshuparashar085@gmail.com'
            )
        }
    }
}
