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
            description: 'Select Terraform action'
        )
    }

    environment {
        AWS_DEFAULT_REGION      = 'ap-southeast-2'
        AWS_REGION              = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID = '129911414812'
        AWS_CREDENTIALS_ID      = 'aws-jenkins-credentials'
        TF_VAR_FILE             = 'environments/dev/terraform.tfvars'
        TF_STATE_BUCKET         = 'employee-management-terraform-state'
        TF_STATE_KEY            = 'employee-management/dev/terraform.tfstate'
        TF_IN_AUTOMATION        = 'true'
        TF_INPUT                = 'false'
    }

    stages {
        stage('Checkout and Verify') {
            steps {
                checkout scm

                sh '''
                    set -eu
                    command -v aws
                    command -v terraform
                    test -f backend.tf
                    test -f main.tf
                    test -f "$TF_VAR_FILE"

                    aws --version
                    terraform version
                '''

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        echo "Authenticated AWS account: $ACCOUNT_ID"

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID" || {
                            echo "ERROR: Unexpected AWS account."
                            exit 1
                        }
                    '''
                }
            }
        }

        stage('Bootstrap State Bucket') {
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

                        if ! aws s3api head-bucket \
                            --bucket "$TF_STATE_BUCKET" 2>/dev/null; then

                            echo "Creating state bucket..."

                            aws s3api create-bucket \
                                --bucket "$TF_STATE_BUCKET" \
                                --region "$AWS_DEFAULT_REGION" \
                                --create-bucket-configuration \
                                "LocationConstraint=$AWS_DEFAULT_REGION"
                        fi

                        aws s3api put-public-access-block \
                            --bucket "$TF_STATE_BUCKET" \
                            --public-access-block-configuration \
                            'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

                        aws s3api put-bucket-ownership-controls \
                            --bucket "$TF_STATE_BUCKET" \
                            --ownership-controls \
                            'Rules=[{ObjectOwnership=BucketOwnerEnforced}]'

                        aws s3api put-bucket-versioning \
                            --bucket "$TF_STATE_BUCKET" \
                            --versioning-configuration Status=Enabled

                        aws s3api put-bucket-encryption \
                            --bucket "$TF_STATE_BUCKET" \
                            --server-side-encryption-configuration \
                            '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

                        echo "State bucket configuration completed."
                        echo "This stage does not restore a missing Terraform state file."
                    '''
                }
            }
        }

        stage('Initialize, Validate and Plan') {
            when {
                expression {
                    params.ACTION == 'plan' ||
                    params.ACTION == 'apply' ||
                    params.ACTION == 'destroy'
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        echo "Checking Terraform state object..."

                        aws s3api head-object \
                            --bucket "$TF_STATE_BUCKET" \
                            --key "$TF_STATE_KEY" \
                            >/dev/null || {
                                echo "ERROR: Terraform state is missing or inaccessible."
                                echo "Recover or reconstruct the correct state before proceeding."
                                exit 1
                            }

                        echo "Initializing Terraform..."

                        attempt=1
                        until terraform init -input=false -reconfigure; do
                            if [ "$attempt" -ge 3 ]; then
                                echo "ERROR: Terraform initialization failed."
                                exit 1
                            fi

                            attempt=$((attempt + 1))
                            echo "Retrying Terraform init ($attempt/3)..."
                            sleep 5
                        done

                        terraform fmt -check -recursive
                        terraform validate

                        if [ "$ACTION" = "destroy" ]; then
                            terraform plan \
                                -destroy \
                                -input=false \
                                -var-file="$TF_VAR_FILE" \
                                -out=destroy.tfplan

                            terraform show -no-color destroy.tfplan
                        else
                            terraform plan \
                                -input=false \
                                -var-file="$TF_VAR_FILE" \
                                -out=tfplan

                            terraform show -no-color tfplan
                        fi
                    '''
                }
            }
        }

        stage('Approve and Execute') {
            when {
                expression {
                    params.ACTION == 'apply' ||
                    params.ACTION == 'destroy'
                }
            }
            steps {
                script {
                    def isDestroy = params.ACTION == 'destroy'

                    input(
                        message: isDestroy
                            ? 'DESTROY infrastructure in account 129911414812, region ap-southeast-2?'
                            : 'APPLY Terraform changes in account 129911414812, region ap-southeast-2?',
                        ok: 'Approve'
                    )
                }

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"

                        if [ "$ACTION" = "destroy" ]; then
                            test -f destroy.tfplan
                            terraform apply -input=false destroy.tfplan
                        else
                            test -f tfplan
                            terraform apply -input=false tfplan
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Completed ACTION=${params.ACTION}."
        }

        failure {
            echo 'Pipeline failed. Review the Console Output.'
        }

        always {
            archiveArtifacts(
                artifacts: 'tfplan,destroy.tfplan',
                allowEmptyArchive: true
            )

            deleteDir()
        }
    }
}