pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action'
        )
    }

    environment {
        AWS_DEFAULT_REGION      = 'ap-southeast-2'
        AWS_REGION              = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID = '129911414812'
        TF_VAR_FILE             = 'environments/dev/terraform.tfvars'
        AWS_CREDENTIALS_ID      = 'aws-jenkins-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init and Validate') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        echo "AWS account: $ACCOUNT_ID"

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Wrong AWS account. Expected $EXPECTED_AWS_ACCOUNT_ID."
                            exit 1
                        fi

                        terraform init -input=false
                        terraform fmt -check -recursive
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu
                        test -f "$TF_VAR_FILE"
                        terraform plan -input=false -var-file="$TF_VAR_FILE" -out=tfplan
                        terraform show -no-color tfplan
                    '''
                }
            }
        }

        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                input(
                    message: "Approve Terraform ${params.ACTION} in AWS account 129911414812, region ap-southeast-2?",
                    ok: 'Approve'
                )
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: AWS account mismatch; apply blocked."
                            exit 1
                        fi

                        test -f tfplan
                        terraform apply -input=false -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: AWS account mismatch; destroy blocked."
                            exit 1
                        fi

                        test -f "$TF_VAR_FILE"
                        terraform destroy -input=false -var-file="$TF_VAR_FILE"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform pipeline completed successfully.'
        }
        failure {
            echo 'Terraform pipeline failed. Check the console output.'
        }
        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}
