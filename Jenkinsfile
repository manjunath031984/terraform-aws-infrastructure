pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the main Terraform action'
        )
    }

    environment {
        AWS_DEFAULT_REGION       = 'ap-southeast-2'
        AWS_REGION               = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID  = '129911414812'
        AWS_CREDENTIALS_ID       = 'aws-jenkins-credentials'
        TF_VAR_FILE              = 'environments/dev/terraform.tfvars'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify AWS Account') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        echo "Authenticated AWS account: $ACCOUNT_ID"

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Expected AWS account $EXPECTED_AWS_ACCOUNT_ID."
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Bootstrap State Resources') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    dir('bootstrap') {
                        sh '''
                            set -eu
                            terraform init -input=false
                            terraform fmt -check
                            terraform validate
                            terraform plan -input=false -out=bootstrap.tfplan
                            terraform apply -input=false -auto-approve bootstrap.tfplan
                        '''
                    }
                }
            }
        }

        stage('Main Terraform Init and Validate') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu
                        test -f "$TF_VAR_FILE"
                        terraform init -input=false
                        terraform fmt -check -recursive
                        terraform validate
                    '''
                }
            }
        }

        stage('Main Terraform Plan') {
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
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"
                        terraform plan -input=false -var-file="$TF_VAR_FILE" -out=tfplan
                        terraform show -no-color tfplan
                    '''
                }
            }
        }

        stage('Main Terraform Destroy Plan') {
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
                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"
                        terraform plan -destroy -input=false -var-file="$TF_VAR_FILE" -out=destroy.tfplan
                        terraform show -no-color destroy.tfplan
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
                    message: "Review the plan and approve ACTION=${params.ACTION} for AWS account 129911414812 in ap-southeast-2.",
                    ok: 'Approve'
                )
            }
        }

        stage('Main Terraform Apply') {
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
                        terraform apply -input=false tfplan
                    '''
                }
            }
        }

        stage('Main Terraform Destroy') {
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
                        test -f destroy.tfplan
                        terraform apply -input=false destroy.tfplan
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
            // Archive Terraform plans before deleting the workspace.
            archiveArtifacts artifacts: 'tfplan,destroy.tfplan,bootstrap/bootstrap.tfplan', allowEmptyArchive: true

            echo 'Cleaning Jenkins workspace...'
            deleteDir()
            echo 'Workspace cleanup completed.'
        }
    }
}
