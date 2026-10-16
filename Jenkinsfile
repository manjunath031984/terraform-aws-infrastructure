pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        skipDefaultCheckout(true)
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['destroy-buckets'],
            description: 'Permanently delete both Terraform state buckets'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-southeast-2'
        AWS_REGION = 'ap-southeast-2'
        EXPECTED_AWS_ACCOUNT_ID = '129911414812'
        AWS_CREDENTIALS_ID = 'aws-jenkins-credentials'
    }

    stages {
        stage('Verify Tools') {
            steps {
                sh '''
                    set -eu
                    command -v aws
                    aws --version
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

                        echo "Authenticated AWS account: ${ACCOUNT_ID}"

                        if [ "$ACCOUNT_ID" != "$EXPECTED_AWS_ACCOUNT_ID" ]; then
                            echo "ERROR: Unexpected AWS account. Aborting."
                            exit 1
                        fi

                        echo "AWS account verification successful."
                    '''
                }
            }
        }

        stage('Review Target Buckets') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        for BUCKET in \
                            employee-management-terraform-state \
                            employee-management-terraform-state-ap-southeast-2
                        do
                            echo "Checking bucket: ${BUCKET}"

                            if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
                                aws s3api get-bucket-location --bucket "$BUCKET"
                            else
                                echo "Bucket not found or access denied: ${BUCKET}"
                            fi
                        done
                    '''
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    input(
                        message: '''
PERMANENT DELETION WARNING

This pipeline will permanently delete these buckets
and all object versions and delete markers:

1. employee-management-terraform-state
2. employee-management-terraform-state-ap-southeast-2

This can destroy Terraform state and prevent the existing
Terraform backend from initializing.

Confirm that you have backed up any state you need.
''',
                        ok: 'DELETE BOTH BUCKETS'
                    )
                }
            }
        }

        stage('Delete Both Buckets') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        # Delete every object version / delete marker of one type
                        # (Versions or DeleteMarkers), 1000 at a time.
                        purge() {
                            BUCKET="$1"
                            TYPE="$2"
                            LOOPS=0

                            while true; do
                                FIRST=$(aws s3api list-object-versions \
                                    --bucket "$BUCKET" --max-items 1 \
                                    --query "${TYPE}[0].Key" --output text)

                                if [ -z "$FIRST" ] || [ "$FIRST" = "None" ]; then
                                    break
                                fi

                                LOOPS=$((LOOPS + 1))
                                if [ "$LOOPS" -gt 500 ]; then
                                    echo "ERROR: too many delete loops for ${BUCKET}. Aborting."
                                    exit 1
                                fi

                                PAYLOAD=$(aws s3api list-object-versions \
                                    --bucket "$BUCKET" --max-items 1000 \
                                    --query "{Objects: ${TYPE}[].{Key:Key,VersionId:VersionId}}" \
                                    --output json)

                                aws s3api delete-objects \
                                    --bucket "$BUCKET" \
                                    --delete "$PAYLOAD" > /dev/null

                                echo "Deleted a batch of ${TYPE} from ${BUCKET}"
                            done
                        }

                        for BUCKET in \
                            employee-management-terraform-state \
                            employee-management-terraform-state-ap-southeast-2
                        do
                            echo ""
                            echo "Processing bucket: ${BUCKET}"

                            if ! aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
                                echo "Bucket unavailable or not found: ${BUCKET}. Aborting to avoid deleting the wrong resource."
                                exit 1
                            fi

                            LOCATION=$(aws s3api get-bucket-location \
                                --bucket "$BUCKET" \
                                --query LocationConstraint --output text)

                            if [ "$LOCATION" != "ap-southeast-2" ]; then
                                echo "Unexpected region for ${BUCKET}: ${LOCATION}. Aborting."
                                exit 1
                            fi

                            purge "$BUCKET" Versions
                            purge "$BUCKET" DeleteMarkers

                            aws s3api delete-bucket --bucket "$BUCKET"
                            echo "Successfully deleted bucket: ${BUCKET}"
                        done

                        echo "Both requested buckets have been deleted."
                    '''
                }
            }
        }

        stage('Verify Deletion') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    sh '''
                        set -eu

                        for BUCKET in \
                            employee-management-terraform-state \
                            employee-management-terraform-state-ap-southeast-2
                        do
                            if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
                                echo "ERROR: Bucket still exists: $BUCKET"
                                exit 1
                            else
                                echo "Bucket is absent or inaccessible: $BUCKET"
                            fi
                        done
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Bucket deletion pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Review Console Output before retrying.'
        }
        always {
            echo 'Cleaning Jenkins workspace...'
            deleteDir()
            echo 'Workspace cleanup completed.'
        }
    }
}