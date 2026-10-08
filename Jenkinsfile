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
            description: 'Select the Terraform action'
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
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-credentials']
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
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-credentials']
                ]) {
                    sh '''
                        set -e

                        echo "======================================"
                        echo "Terraform Plan"
                        echo "======================================"

                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Approval') {
            when {
                expression {
                    return params.ACTION == 'apply' ||
                           params.ACTION == 'destroy'
                }
            }

            steps {
                script {

                    if (params.ACTION == 'apply') {

                        input(
                            message: 'Do you want to APPLY the Terraform infrastructure?',
                            ok: 'Approve Apply'
                        )

                    } else {

                        input(
                            message: 'WARNING: Do you want to DESTROY the Terraform infrastructure?',
                            ok: 'Approve Destroy'
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    return params.ACTION == 'apply'
                }
            }

            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-credentials']
                ]) {
                    sh '''
                        set -e

                        echo "======================================"
                        echo "Terraform Apply"
                        echo "======================================"

                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    return params.ACTION == 'destroy'
                }
            }

            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-credentials']
                ]) {
                    sh '''
                        set -e

                        echo "======================================"
                        echo "Terraform Destroy"
                        echo "======================================"

                        terraform destroy -auto-approve
                    '''
                }
            }
        }

        stage('Terraform Outputs') {
            when {
                expression {
                    return params.ACTION == 'apply'
                }
            }

            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-credentials']
                ]) {
                    sh '''
                        echo "======================================"
                        echo "Terraform Outputs"
                        echo "======================================"

                        terraform output
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

        always {
            sh '''
                rm -f tfplan 2>/dev/null || true
            '''
        }
    }
}