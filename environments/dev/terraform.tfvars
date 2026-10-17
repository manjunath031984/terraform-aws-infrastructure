
aws_region   = "ap-southeast-2"
project_name = "employee-management"
environment  = "dev"
vpc_cidr     = "10.0.0.0/16"

eks_cluster_name    = "employee-management-eks"
eks_cluster_version = "1.36"

# Replace with your trusted public IPv4 address /32.
eks_api_allowed_cidrs = ["103.203.36.81/32"]

enable_nat_gateway = true
single_nat_gateway = true

postgres_instance_types = ["t3.small"]
employee_instance_types = ["t3.small"]

node_disk_size = 30

tags = {
  Owner = "DevSecOps"
}
