```groovy
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
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_REGION = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
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
                        set -e

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
                        echo "Terraform Init"
                        echo "======================================"
                        terraform init -upgrade

                        echo ""
                        echo "======================================"
                        echo "Terraform Format Check"
                        echo "======================================"
                        terraform fmt -check -recursive

                        echo ""
                        echo "======================================"
                        echo "Terraform Validate"
                        echo "======================================"
                        terraform validate

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
                        set -e

                        echo "======================================"
                        echo "Terraform Plan"
                        echo "======================================"

                        terraform plan \
                            -var-file="environments/dev/terraform.tfvars" \
                            -out=tfplan

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
                            message: 'Do you want to APPLY the Terraform infrastructure?',
                            ok: 'Proceed'
                        )
                    } else {
                        input(
                            message: 'WARNING: Do you want to DESTROY the Terraform infrastructure?',
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
                        set -e

                        echo "======================================"
                        echo "Terraform Apply"
                        echo "======================================"

                        terraform apply -auto-approve tfplan

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
                        set -e

                        echo "======================================"
                        echo "Terraform Destroy"
                        echo "======================================"

                        terraform destroy \
                            -var-file="environments/dev/terraform.tfvars" \
                            -auto-approve

                        echo ""
                        echo "Terraform Destroy Completed Successfully"
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
                        set -e

                        echo "======================================"
                        echo "Terraform Outputs"
                        echo "======================================"

                        terraform output

                        echo ""
                        echo "Terraform Outputs Retrieved Successfully"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "======================================"
            echo "Terraform Pipeline Completed Successfully"
            echo "======================================"
        }

        failure {
            echo "======================================"
            echo "Terraform Pipeline Failed"
            echo "Please check the Jenkins console logs."
            echo "======================================"
        }

        aborted {
            echo "======================================"
            echo "Terraform Pipeline Aborted"
            echo "======================================"
        }

        always {
            sh '''
                rm -f tfplan 2>/dev/null || true
            '''
        }
    }
}
```