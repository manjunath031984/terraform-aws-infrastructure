
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 60, unit: 'MINUTES')
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the Terraform action to execute.'
        )
    }

    environment {
        AWS_DEFAULT_REGION      = 'ap-southeast-2'
        AWS_REGION              = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID = '129911414812'
        AWS_CREDENTIALS_ID      = 'aws-jenkins-credentials'
        TF_VAR_FILE             = 'environments/dev/terraform.tfvars'
        TF_IN_AUTOMATION        = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools and AWS Account') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        command -v terraform
                        command -v aws

                        terraform version
                        aws --version

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        echo "Authenticated AWS account: ${ACCOUNT_ID}"
                        echo "AWS region: ${AWS_DEFAULT_REGION}"

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: AWS account mismatch."
                            echo "Expected: $EXPECTED_AWS_ACCOUNT_ID"
                            echo "Actual:   $ACCOUNT_ID"
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

                            terraform plan \
                                -input=false \
                                -out=bootstrap.tfplan

                            terraform show -no-color bootstrap.tfplan

                            # Preserve the existing bootstrap-first flow.
                            # Bootstrap resources must be protected from
                            # accidental destruction.
                            terraform apply \
                                -input=false \
                                bootstrap.tfplan
                        '''
                    }
                }
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

                        test -f "$TF_VAR_FILE" || {
                            echo "ERROR: Terraform variable file not found: $TF_VAR_FILE"
                            exit 1
                        }

                        terraform init -input=false
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"

                        terraform plan \
                            -input=false \
                            -var-file="$TF_VAR_FILE" \
                            -out=tfplan

                        echo "========== Terraform Plan =========="
                        terraform show -no-color tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy Plan') {
            when {
                expression {
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        test "$ACCOUNT_ID" = "$EXPECTED_AWS_ACCOUNT_ID"

                        terraform plan \
                            -destroy \
                            -input=false \
                            -var-file="$TF_VAR_FILE" \
                            -out=destroy.tfplan

                        echo "========== Terraform Destroy Plan =========="
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
                    def approvalMessage = params.ACTION == 'destroy'
                        ? 'WARNING: Approve destruction of the Terraform-managed infrastructure only after reviewing destroy.tfplan.'
                        : 'Approve creation or modification of infrastructure only after reviewing tfplan.'

                    input(
                        message: "${approvalMessage}\nAWS account: ${env.EXPECTED_AWS_ACCOUNT_ID}\nRegion: ${env.AWS_DEFAULT_REGION}",
                        ok: 'Approve',
                        submitterParameter: 'APPROVED_BY'
                    )
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    params.ACTION == 'apply'
                }
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

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Account mismatch. Apply blocked."
                            exit 1
                        fi

                        test -f tfplan || {
                            echo "ERROR: Saved Terraform plan not found."
                            exit 1
                        }

                        terraform apply \
                            -input=false \
                            tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
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

                        ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account --output text)

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Account mismatch. Destroy blocked."
                            exit 1
                        fi

                        test -f destroy.tfplan || {
                            echo "ERROR: Saved destroy plan not found."
                            exit 1
                        }

                        # Apply the reviewed destroy plan.
                        terraform apply \
                            -input=false \
                            destroy.tfplan
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Terraform pipeline completed successfully. ACTION=${params.ACTION}"
        }

        failure {
            echo 'Terraform pipeline failed. Review the Jenkins console output.'
        }

        aborted {
            echo 'Terraform pipeline was aborted.'
        }

        always {
            // Archive plans before removing the workspace.
            archiveArtifacts(
                artifacts: 'tfplan,destroy.tfplan,bootstrap/bootstrap.tfplan',
                allowEmptyArchive: true,
                fingerprint: true
            )

            echo 'Cleaning Jenkins workspace...'
            deleteDir()
            echo 'Workspace cleanup completed.'
        }
    }
}
