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
        booleanParam(
            name: 'ALLOW_EMPTY_STATE_APPLY',
            defaultValue: false,
            description: 'Enable only for an intentional fresh deployment when Terraform state is empty and you have verified the backend, workspace, and AWS resources.'
        )
    }
    environment {
        TF_IN_AUTOMATION      = 'true'
        TF_INPUT              = 'false'
        AWS_DEFAULT_REGION    = 'us-east-1'
        AWS_REGION            = 'us-east-1'
        TF_PLUGIN_CACHE_DIR   = '/var/jenkins_home/.terraform.d/plugin-cache'
        TF_INIT_MAX_ATTEMPTS  = '4'
        TF_VAR_FILE           = 'environments/dev/terraform.tfvars'
        HELM_CHART_DIR        = 'charts/nginx-ingress'
        EKS_CLUSTER_NAME      = 'Employee-Management-eks'
        NGINX_NAMESPACE       = 'nginx-ingress'
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
                    command -v helm >/dev/null 2>&1 || {
                        echo "ERROR: Helm CLI is not installed or not available on PATH."
                        exit 1
                    }
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
                    helm dependency list "$HELM_CHART_DIR"
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
                        echo "EKS Authentication and Connectivity Preflight"
                        echo "======================================"
                        echo "Checking AWS CLI token generation..."
                        aws eks get-token \
                            --cluster-name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION" >/dev/null
                        echo "Configuring kubectl context..."
                        aws eks update-kubeconfig \
                            --name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION" \
                            --alias "$EKS_CLUSTER_NAME-ci"
                        echo "Checking Kubernetes API access..."
                        kubectl get namespaces --request-timeout=20s
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
                            delay=$((5 << (attempt - 1)))
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
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins-credentials'
                    ]]) {
                        sh '''
                            set -eu
                            echo "Checking Terraform state before a mutating action..."
                            echo "AWS account:"
                            aws sts get-caller-identity
                            echo "Terraform workspace:"
                            terraform workspace show
                            state_file="$(mktemp)"
                            trap 'rm -f "$state_file"' EXIT
                            if ! terraform state list > "$state_file"; then
                                echo "ERROR: Unable to read Terraform state. Refusing to continue."
                                exit 1
                            fi
                            if [ ! -s "$state_file" ]; then
                                echo "WARNING: Terraform state contains no tracked resources."
                                if [ "$ACTION" = "destroy" ]; then
                                    echo "ERROR: Destroy is blocked because the state is empty. Terraform cannot destroy resources it does not track."
                                    echo "Verify the backend/workspace and recover or import state if infrastructure already exists."
                                    exit 1
                                fi
                                if [ "$ACTION" = "apply" ]; then
                                    if [ "$ALLOW_EMPTY_STATE_APPLY" != "true" ]; then
                                        echo "ERROR: Apply is blocked because state is empty and ALLOW_EMPTY_STATE_APPLY is false."
                                        echo "For an intentional fresh deployment, verify the backend, workspace, and AWS resources, then rerun with ALLOW_EMPTY_STATE_APPLY enabled."
                                        exit 1
                                    fi
                                    echo "Explicit fresh-deployment override enabled. Continue only after verifying no conflicting resources exist in AWS."
                                fi
                            else
                                echo "Tracked Terraform resources:"
                                cat "$state_file"
                                echo "State safety check passed."
                            fi
                        '''
                    }
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
                            message: 'Review the Terraform plan above. Confirm the AWS account, workspace, and planned resources before APPLY.',
                            ok: 'Proceed'
                        )
                    } else {
                        input(
                            message: 'WARNING: This will DESTROY Terraform-managed infrastructure. Confirm the AWS account, workspace, backend, and state are correct.',
                            ok: 'Proceed'
                        )
                    }
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
        stage('Validate EKS Infrastructure') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh '''
                        set -eu
                        echo "======================================"
                        echo "Validate EKS Cluster and Node Groups"
                        echo "======================================"
                        command -v aws >/dev/null 2>&1 || { echo "ERROR: AWS CLI is missing."; exit 1; }
                        command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is missing from the Jenkins agent/container."; exit 1; }
                        aws eks wait cluster-active \
                            --name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION"
                        aws eks describe-cluster \
                            --name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION" \
                            --query 'cluster.{Name:name,Status:status,Version:version}' \
                            --output table
                        NODEGROUPS=$(aws eks list-nodegroups \
                            --cluster-name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION" \
                            --query 'nodegroups[]' \
                            --output text)
                        if [ -z "$NODEGROUPS" ] || [ "$NODEGROUPS" = "None" ]; then
                            echo "ERROR: No managed node groups found."
                            exit 1
                        fi
                        for NODEGROUP in $NODEGROUPS; do
                            STATUS=$(aws eks describe-nodegroup \
                                --cluster-name "$EKS_CLUSTER_NAME" \
                                --nodegroup-name "$NODEGROUP" \
                                --region "$AWS_REGION" \
                                --query 'nodegroup.status' \
                                --output text)
                            echo "Node group $NODEGROUP status: $STATUS"
                            if [ "$STATUS" != "ACTIVE" ]; then
                                echo "ERROR: Node group $NODEGROUP is not ACTIVE."
                                exit 1
                            fi
                        done
                        echo "Configuring kubectl..."
                        aws eks update-kubeconfig \
                            --name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION"
                        echo "Checking Kubernetes node readiness..."
                        kubectl get nodes -o wide
                        kubectl wait --for=condition=Ready nodes --all --timeout=10m
                        echo "Checking EKS add-on status..."
                        ADDONS=$(aws eks list-addons \
                            --cluster-name "$EKS_CLUSTER_NAME" \
                            --region "$AWS_REGION" \
                            --query 'addons[]' \
                            --output text)
                        for ADDON in $ADDONS; do
                            STATUS=$(aws eks describe-addon \
                                --cluster-name "$EKS_CLUSTER_NAME" \
                                --addon-name "$ADDON" \
                                --region "$AWS_REGION" \
                                --query 'addon.status' \
                                --output text)
                            echo "Add-on $ADDON status: $STATUS"
                            if [ "$STATUS" != "ACTIVE" ]; then
                                echo "ERROR: Add-on $ADDON is not ACTIVE."
                                exit 1
                            fi
                        done
                        echo "Checking storage drivers and classes..."
                        kubectl get csidriver
                        kubectl get storageclass
                        kubectl get pods -n kube-system -o wide
                        echo "Checking NGINX Ingress namespace and pods..."
                        if kubectl get namespace "$NGINX_NAMESPACE" >/dev/null 2>&1; then
                            kubectl get pods -n "$NGINX_NAMESPACE" -o wide
                        else
                            echo "WARNING: Namespace $NGINX_NAMESPACE was not found; verify the configured namespace variable."
                        fi
                        echo "EKS infrastructure validation completed."
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
                expression { params.ACTION == 'apply' }
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
