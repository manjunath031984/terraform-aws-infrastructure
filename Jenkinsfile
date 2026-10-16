
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
                    command -v python3
                    aws --version
                    python3 --version
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

                            if aws s3api head-bucket \
                                --bucket "$BUCKET" 2>/dev/null; then
                                aws s3api get-bucket-location \
                                    --bucket "$BUCKET"
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

                        python3 - <<'PY'
import json
import subprocess
import sys

buckets = [
    "employee-management-terraform-state",
    "employee-management-terraform-state-ap-southeast-2",
]

region = "ap-southeast-2"

def aws_json(*args):
    result = subprocess.run(
        ["aws", *args, "--region", region, "--output", "json"],
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"AWS CLI failed: {' '.join(args)}\\n{result.stderr}"
        )
    return json.loads(result.stdout or "{}")

def aws_run(*args):
    subprocess.run(
        ["aws", *args, "--region", region],
        check=True,
    )

account = aws_json(
    "sts", "get-caller-identity"
)["Account"]

if account != "129911414812":
    sys.exit(f"Unexpected AWS account: {account}. Aborting.")

for bucket in buckets:
    print(f"\\nProcessing bucket: {bucket}", flush=True)

    check = subprocess.run(
        [
            "aws", "s3api", "head-bucket",
            "--bucket", bucket,
            "--region", region,
        ],
        capture_output=True,
        text=True,
    )

    if check.returncode != 0:
        print(
            f"Bucket unavailable or not found: {bucket}. "
            "Aborting to avoid deleting the wrong resource."
        )
        sys.exit(1)

    # Ensure the bucket is in the expected region.
    location = aws_json(
        "s3api", "get-bucket-location",
        "--bucket", bucket,
    ).get("LocationConstraint")

    if location not in (None, "ap-southeast-2"):
        sys.exit(
            f"Unexpected region for {bucket}: {location}. Aborting."
        )

    # AWS CLI automatically paginates list-object-versions.
    versions = aws_json(
        "s3api", "list-object-versions",
        "--bucket", bucket,
    )

    objects = [
        {"Key": item["Key"], "VersionId": item["VersionId"]}
        for item in versions.get("Versions", [])
    ]
    objects.extend(
        {"Key": item["Key"], "VersionId": item["VersionId"]}
        for item in versions.get("DeleteMarkers", [])
    )

    # Delete in batches of at most 1000 objects.
    for start in range(0, len(objects), 1000):
        batch = objects[start:start + 1000]

        payload = json.dumps({
            "Objects": batch,
            "Quiet": True,
        })

        result = subprocess.run(
            [
                "aws", "s3api", "delete-objects",
                "--bucket", bucket,
                "--delete", payload,
                "--region", region,
                "--output", "json",
            ],
            text=True,
            capture_output=True,
        )

        if result.returncode != 0:
            raise RuntimeError(
                f"Failed deleting objects from {bucket}: "
                f"{result.stderr}"
            )

        response = json.loads(result.stdout or "{}")
        if response.get("Errors"):
            raise RuntimeError(
                f"Deletion errors in {bucket}: "
                f"{response['Errors']}"
            )

        print(
            f"Deleted batch of {len(batch)} versions/markers.",
            flush=True,
        )

    # Verify the bucket has no versions or delete markers left.
    remaining = aws_json(
        "s3api", "list-object-versions",
        "--bucket", bucket,
    )

    if remaining.get("Versions") or remaining.get("DeleteMarkers"):
        sys.exit(f"Bucket still contains versions or markers: {bucket}")

    aws_run("s3api", "delete-bucket", "--bucket", bucket)
    print(f"Successfully deleted bucket: {bucket}", flush=True)

print("\\nBoth requested buckets have been deleted.")
PY
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
                            if aws s3api head-bucket \
                                --bucket "$BUCKET" 2>/dev/null; then
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
