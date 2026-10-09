
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the Terraform action to perform'
        )
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_REGION = 'us-east-1'

        // Persistent cache on the Jenkins agent.
        TF_PLUGIN_CACHE_DIR = '/var/jenkins_home/.terraform.d/plugin-cache'

        // Retry configuration for provider downloads.
        TF_INIT_MAX_ATTEMPTS = '4'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Terraform Provider Cache') {
            steps {
                sh '''
                    set -eu

                    echo "======================================"
                    echo "Preparing Terraform Provider Cache"
                    echo "======================================"

                    mkdir -p "$TF_PLUGIN_CACHE_DIR"

                    if [ ! -w "$TF_PLUGIN_CACHE_DIR" ]; then
                        echo "ERROR: Terraform provider cache is not writable."
                        exit 1
                    fi

                    echo "Provider cache: $TF_PLUGIN_CACHE_DIR"
                    df -h "$TF_PLUGIN_CACHE_DIR"
                '''
            }
        }

        stage('Terraform Setup & Validation') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]
                ]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "AWS Identity"
                        echo "======================================"
                        aws sts get-caller-identity

                        echo ""
                        echo "======================================"
                        echo "Terraform Version"
                        echo "======================================"
                        terraform version

                        echo ""
                        echo "======================================"
                        echo "AWS CLI Version"
                        echo "======================================"
                        aws --version

                        echo ""
                        echo "======================================"
                        echo "Terraform Init with Retry"
                        echo "======================================"

                        attempt=1
                        max_attempts="$TF_INIT_MAX_ATTEMPTS"

                        until terraform init -input=false -no-color; do
                            if [ "$attempt" -ge "$max_attempts" ]; then
                                echo "ERROR: Terraform initialization failed after $attempt attempts."
                                exit 1
                            fi

                            delay=$((5 * (2 ** (attempt - 1))))

                            echo "Terraform init failed on attempt $attempt."
                            echo "Retrying in $delay seconds..."

                            sleep "$delay"
                            attempt=$((attempt + 1))
                        done

                        echo ""
                        echo "======================================"
                        echo "Terraform Format Check"
                        echo "======================================"
                        terraform fmt -check -recursive

                        echo ""
                        echo "======================================"
                        echo "Terraform Validate"
                        echo "======================================"
                        terraform validate -no-color

                        echo ""
                        echo "Terraform Setup & Validation Completed"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]
                ]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Plan"
                        echo "======================================"

                        terraform plan \
                            -input=false \
                            -no-color \
                            -var-file="environments/dev/terraform.tfvars" \
                            -out=tfplan

                        echo ""
                        echo "Readable Terraform Plan"
                        terraform show -no-color tfplan

                        echo ""
                        echo "Terraform Plan Completed Successfully"
                    '''
                }
            }
        }

        stage('Approval') {
            when {
                expression {
                    params.ACTION == 'apply' ||
                    params.ACTION == 'destroy'
                }
            }

            steps {
                script {
                    if (params.ACTION == 'apply') {
                        input(
                            message: 'Review the Terraform plan. Do you want to APPLY the infrastructure changes?',
                            ok: 'Proceed'
                        )
                    } else {
                        input(
                            message: 'WARNING: This will DESTROY managed infrastructure. Do you want to continue?',
                            ok: 'Proceed'
                        )
                    }
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
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]
                ]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Apply"
                        echo "======================================"

                        if [ ! -f tfplan ]; then
                            echo "ERROR: Saved Terraform plan not found."
                            exit 1
                        fi

                        terraform apply \
                            -input=false \
                            -no-color \
                            -auto-approve \
                            tfplan

                        echo ""
                        echo "Terraform Apply Completed Successfully"
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
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]
                ]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Destroy"
                        echo "======================================"

                        terraform destroy \
                            -input=false \
                            -no-color \
                            -var-file="environments/dev/terraform.tfvars"

                        echo ""
                        echo "Terraform Destroy Completed"
                    '''
                }
            }
        }

        stage('Terraform Outputs') {
            when {
                expression {
                    params.ACTION == 'apply'
                }
            }

            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]
                ]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Outputs"
                        echo "======================================"

                        terraform output -no-color

                        echo ""
                        echo "Terraform Outputs Retrieved Successfully"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'Terraform Pipeline Completed Successfully'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'Terraform Pipeline Failed'
            echo 'Check the Jenkins console logs for details.'
            echo '======================================'
        }

        aborted {
            echo '======================================'
            echo 'Terraform Pipeline Aborted'
            echo '======================================'
        }

        always {
            sh '''
                rm -f tfplan 2>/dev/null || true
            '''
        }
    }
}
