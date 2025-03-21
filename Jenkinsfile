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
        stage('Run Ansible Playbook') {
            steps {
                script {
                    def ansibleFailed = false
                    dir('roles_kafka_dynamic') {
                        try {
                            sh '''
                            set -e
                            echo "Checking required files..."
                            ls -l kafka-zookeeper/tests
                            test -f aws_ec2.yaml || (echo "ERROR: aws_ec2.yaml not found!" && exit 1)
                            test -f kafka-zookeeper/tests/test.yaml || (echo "ERROR: test.yaml not found!" && exit 1)

                            echo "Running Ansible Playbook..."
                            ansible-playbook -i aws_ec2.yaml kafka-zookeeper/tests/test.yaml --private-key /var/lib/jenkins/workspace/vmkey.pem
                            '''
                        } catch (Exception e) {
                            ansibleFailed = true
                            echo "Ansible playbook execution failed: ${e}"
                        }
                    }
                    if (ansibleFailed) {
                        echo "Ansible playbook failed! Proceeding with next steps."
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('Run Kafka Backup Script') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh '''
                        set -e
                        echo "Installing required dependencies..."
                        sudo apt update
                        sudo apt install dos2unix unzip -y

                        echo "Checking AWS CLI installation..."
                        if ! aws --version | grep -q 'aws-cli/2'; then
                            echo "Installing AWS CLI..."
                            sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
                            sudo unzip -o /tmp/awscliv2.zip -d /tmp
                            sudo /tmp/aws/install --update
                        else
                            echo "AWS CLI already installed."
                        fi
                        sudo aws --version

                        echo "Ensuring /opt/kafka directory exists..."
                        sudo mkdir -p /opt/kafka
                        sudo chown -R $(whoami):$(whoami) /opt/kafka
                        sudo chmod -R 755 /opt/kafka

                        echo "Exporting AWS Credentials..."
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

                        echo "Verifying AWS Credentials..."
                        sudo -E aws sts get-caller-identity || { echo "AWS Credentials are not configured properly!"; exit 1; }

                        echo "Downloading Kafka backup script from S3..."
                        sudo -E aws s3 cp s3://parashar085/kafka_backup.sh /opt/kafka/kafka_backup.sh

                        echo "Fixing script permissions..."
                        sudo chmod 755 /opt/kafka/kafka_backup.sh

                        echo "Converting script to Unix format..."
                        sudo dos2unix /opt/kafka/kafka_backup.sh

                        echo "Executing Kafka backup script..."
                        sudo -E /opt/kafka/kafka_backup.sh
                        '''
                    }
                }
            }
        }
        stage('Terraform Destroy') {
            when {
                anyOf {
                    expression { currentBuild.result == 'UNSTABLE' }
                    expression { currentBuild.result == 'ABORTED' }
                    expression { input(
                        message: 'Do you want to destroy the Terraform infrastructure?',
                        parameters: [choice(name: 'CONFIRM', choices: ['Yes', 'No'], description: 'Select Yes to proceed or No to abort')]
                    ) == 'Yes' }
                }
            }
            steps {
                dir('kafka_dynamic/terraformaws5') {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Cleaning up workspace..."
            deleteDir()
        }
        aborted {
            echo "Pipeline was aborted. Triggering Terraform Destroy."
            dir('kafka_dynamic/terraformaws5') {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
        failure {
            emailext(
                subject: "❌ Jenkins Build FAILURE: ${env.JOB_NAME}",
                mimeType: 'text/html',
                body: """
                <h3 style="color: red;">Jenkins Build Failed ❌</h3>
                <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                <p><strong>Status:</strong> ❌ <b>FAILED</b></p>
                <p>View details: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: 'himanshuparashar085@gmail.com'
            )
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
                to: 'himanshuparashar085@gmail.com'
            )
        }
    }
}
