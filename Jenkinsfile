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
        TF_IN_AUTOMATION     = 'true'
        TF_INPUT             = 'false'
        AWS_DEFAULT_REGION   = 'us-east-1'
        AWS_REGION           = 'us-east-1'
        TF_PLUGIN_CACHE_DIR  = '/var/jenkins_home/.terraform.d/plugin-cache'
        TF_INIT_MAX_ATTEMPTS = '4'
        TF_VAR_FILE          = 'environments/dev/terraform.tfvars'
        HELM_CHART_DIR       = 'charts/nginx-ingress'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh '''
                    set -eu
                    echo "======================================"
                    echo "Git Branch and Commit"
                    echo "======================================"
                    git branch --show-current
                    git log -1 --oneline
                    echo
                    echo "Selected Terraform action: $ACTION"
                    echo "AWS Region: $AWS_REGION"
                '''
            }
        }

        stage('Prepare Terraform Provider Cache') {
            steps {
                sh '''
                    set -eu
                    echo "Preparing Terraform provider cache"
                    mkdir -p "$TF_PLUGIN_CACHE_DIR"

                    if [ ! -w "$TF_PLUGIN_CACHE_DIR" ]; then
                        echo "ERROR: Terraform provider cache is not writable: $TF_PLUGIN_CACHE_DIR"
                        exit 1
                    fi

                    echo "Provider cache: $TF_PLUGIN_CACHE_DIR"
                    df -h "$TF_PLUGIN_CACHE_DIR"
                '''
            }
        }

        stage('Build and Validate Helm Chart') {
            steps {
                sh '''
                    set -eu
                    echo "======================================"
                    echo "Build and Validate NGINX Helm Chart"
                    echo "======================================"

                    if ! command -v helm >/dev/null 2>&1; then
                        echo "ERROR: Helm CLI is not installed or not available on PATH."
                        echo "Install Helm in the Jenkins agent/container before running this pipeline."
                        exit 1
                    fi

                    test -f "$HELM_CHART_DIR/Chart.yaml" || {
                        echo "ERROR: Missing $HELM_CHART_DIR/Chart.yaml"
                        exit 1
                    }

                    test -f "$HELM_CHART_DIR/values.yaml" || {
                        echo "ERROR: Missing $HELM_CHART_DIR/values.yaml"
                        exit 1
                    }

                    helm version
                    helm dependency build "$HELM_CHART_DIR"
                    helm lint "$HELM_CHART_DIR"
                '''
            }
        }

        stage('Terraform Setup & Validation') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "AWS Identity"
                        echo "======================================"
                        aws sts get-caller-identity

                        echo
                        echo "======================================"
                        echo "Tool Versions"
                        echo "======================================"
                        terraform version
                        aws --version
                        helm version

                        echo
                        echo "======================================"
                        echo "Terraform Init with Retry"
                        echo "======================================"

                        attempt=1
                        max_attempts="$TF_INIT_MAX_ATTEMPTS"

                        while ! terraform init -input=false -no-color; do
                            if [ "$attempt" -ge "$max_attempts" ]; then
                                echo "ERROR: Terraform init failed after $attempt attempts."
                                exit 1
                            fi

                            delay=$((5 * (2 ** (attempt - 1))))
                            echo "Terraform init failed on attempt $attempt."
                            echo "Retrying in $delay seconds..."
                            sleep "$delay"
                            attempt=$((attempt + 1))
                        done

                        echo
                        echo "======================================"
                        echo "Terraform Format Check"
                        echo "======================================"
                        terraform fmt -check -recursive

                        echo
                        echo "======================================"
                        echo "Terraform Validate"
                        echo "======================================"
                        terraform validate -no-color

                        echo
                        echo "======================================"
                        echo "Terraform Workspace and State Summary"
                        echo "======================================"
                        terraform workspace show
                        terraform state list || true
                    '''
                }
            }
        }

        stage('Terraform State Safety Check') {
            when {
                expression {
                    params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }
            steps {
                sh '''
                    set -eu
                    echo "Checking Terraform state before a mutating action..."

                    state_file="$(mktemp)"
                    trap 'rm -f "$state_file"' EXIT

                    if ! terraform state list > "$state_file"; then
                        echo "ERROR: Unable to read Terraform state."
                        exit 1
                    fi

                    if [ ! -s "$state_file" ]; then
                        echo "ERROR: Terraform state contains no tracked resources."
                        echo "For safety, apply/destroy is blocked because existing AWS infrastructure may be unmanaged by this state."
                        echo "Verify the backend configuration and workspace, restore the correct state backup, or import existing resources before retrying."
                        exit 1
                    fi

                    echo "Tracked Terraform resources:"
                    cat "$state_file"
                    echo "State safety check passed."
                '''
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
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Plan"
                        echo "======================================"

                        test -f "$TF_VAR_FILE" || {
                            echo "ERROR: Variable file not found: $TF_VAR_FILE"
                            exit 1
                        }

                        terraform workspace show

                        terraform plan \
                            -input=false \
                            -no-color \
                            -var-file="$TF_VAR_FILE" \
                            -out=tfplan

                        echo
                        echo "======================================"
                        echo "Readable Terraform Plan"
                        echo "======================================"
                        terraform show -no-color tfplan

                        echo "Terraform plan completed successfully."
                    '''
                }
            }
        }

        stage('Approval') {
            when {
                expression {
                    params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        input(
                            message: 'Review the Terraform plan above. Do you want to APPLY these infrastructure changes?',
                            ok: 'Proceed'
                        )
                    } else {
                        input(
                            message: 'WARNING: This will DESTROY Terraform-managed infrastructure. Confirm the workspace, backend, and state are correct.',
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
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

                        echo "Terraform apply completed successfully."
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
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Destroy"
                        echo "======================================"

                        echo "AWS account:"
                        aws sts get-caller-identity

                        echo "Terraform workspace:"
                        terraform workspace show

                        echo "Resources tracked by Terraform:"
                        terraform state list

                        terraform destroy \
                            -input=false \
                            -no-color \
                            -auto-approve \
                            -var-file="$TF_VAR_FILE"

                        echo "Terraform destroy command completed."
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh '''
                        set -eu

                        echo "======================================"
                        echo "Terraform Outputs"
                        echo "======================================"

                        terraform output -no-color
                        echo "Terraform outputs retrieved successfully."
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
            sh 'rm -f tfplan 2>/dev/null || true'
        }
    }
}
