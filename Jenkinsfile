
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
        skipDefaultCheckout(true)
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['bootstrap', 'plan', 'apply', 'destroy'],
            description: 'Select the Terraform pipeline action'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-southeast-2'
        AWS_REGION = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID = '129911414812'
        AWS_CREDENTIALS_ID = 'aws-jenkins-credentials'
        TF_VAR_FILE = 'environments/dev/terraform.tfvars'
        TF_STATE_BUCKET = 'employee-management-terraform-state'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    set -eu
                    command -v aws
                    command -v terraform
                    aws --version
                    terraform version
                '''
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        echo "Authenticated AWS account: $ACCOUNT_ID"

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Unexpected AWS account."
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Bootstrap Terraform State Bucket') {
            when {
                expression { params.ACTION == 'bootstrap' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        BUCKET="$TF_STATE_BUCKET"
                        REGION="$AWS_DEFAULT_REGION"

                        echo "Bootstrapping Terraform state bucket: $BUCKET"

                        if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
                            echo "Bucket already exists and is accessible."
                        else
                            echo "Creating bucket in $REGION..."

                            aws s3api create-bucket \
                                --bucket "$BUCKET" \
                                --region "$REGION" \
                                --create-bucket-configuration \
                                LocationConstraint="$REGION"
                        fi

                        aws s3api put-public-access-block \
                            --bucket "$BUCKET" \
                            --public-access-block-configuration \
                            'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

                        aws s3api put-bucket-ownership-controls \
                            --bucket "$BUCKET" \
                            --ownership-controls \
                            'Rules=[{ObjectOwnership=BucketOwnerEnforced}]'

                        aws s3api put-bucket-versioning \
                            --bucket "$BUCKET" \
                            --versioning-configuration Status=Enabled

                        aws s3api put-bucket-encryption \
                            --bucket "$BUCKET" \
                            --server-side-encryption-configuration \
                            '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

                        aws s3api head-bucket --bucket "$BUCKET"

                        echo "Terraform state bucket is ready."
                    '''
                }
            }
        }

        stage('Main Terraform Init and Validate') {
            when {
                expression { params.ACTION != 'bootstrap' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        test -f "$TF_VAR_FILE"
                        test -f backend.tf

                        echo "Checking Terraform state bucket..."

                        aws s3api head-bucket \
                            --bucket "$TF_STATE_BUCKET"

                        terraform init -input=false -reconfigure
                        terraform fmt -check -recursive
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    params.ACTION == 'plan' || params.ACTION == 'apply'
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        terraform plan \
                            -input=false \
                            -var-file="$TF_VAR_FILE" \
                            -out=tfplan

                        terraform show -no-color tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy Plan') {
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

                        terraform plan \
                            -destroy \
                            -input=false \
                            -var-file="$TF_VAR_FILE" \
                            -out=destroy.tfplan

                        terraform show -no-color destroy.tfplan
                    '''
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression {
                    params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }
            steps {
                script {
                    def approvalText = params.ACTION == 'destroy'
                        ? 'DESTROY infrastructure in AWS account 129911414812, region ap-southeast-2?'
                        : 'APPLY infrastructure changes to AWS account 129911414812, region ap-southeast-2?'

                    input(
                        message: approvalText,
                        ok: 'Approve'
                    )
                }
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"
                        test -f tfplan

                        terraform apply -input=false tfplan
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"
                        test -f destroy.tfplan

                        terraform apply -input=false destroy.tfplan
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for ACTION=${params.ACTION}."
        }

        failure {
            echo 'Pipeline failed. Review the Console Output.'
        }

        always {
            archiveArtifacts(
                artifacts: 'tfplan,destroy.tfplan',
                allowEmptyArchive: true
            )

            echo 'Cleaning Jenkins workspace...'
            deleteDir()
            echo 'Workspace cleanup completed.'
        }
    }
}
