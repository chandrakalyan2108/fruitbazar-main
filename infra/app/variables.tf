# ---------------------------------------------------------------- general ---
variable "project" {
  description = "Project name, used as a prefix for every resource"
  type        = string
  default     = "fruitbazar"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  description = "AWS region (ap-south-1 = Mumbai, closest to Hyderabad customers)"
  type        = string
  default     = "ap-south-1"
}

# ---------------------------------------------------------------- network ---
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread across (2 recommended)"
  type        = number
  default     = 2
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3 (the ALB and RDS subnet group need at least 2 AZs)."
  }
}

variable "single_nat_gateway" {
  description = "true = one NAT gateway (cheaper); false = one per AZ (survives an AZ outage)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------ application ---
variable "image_tag" {
  description = "Container image tag to deploy (the pipeline passes the git commit SHA)"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory in MiB (must be valid for task_cpu)"
  type        = number
  default     = 1024
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 6
}

variable "cpu_target_percent" {
  description = "Average CPU % that triggers autoscaling"
  type        = number
  default     = 60
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "ecr_force_delete" {
  description = "Allow terraform destroy to delete the ECR repo even if it still contains images"
  type        = bool
  default     = false
}

# --------------------------------------------------------------- database ---
variable "db_engine_version" {
  description = "RDS MySQL major version. 8.4 is the current LTS (8.0 left RDS standard support in 2026)."
  type        = string
  default     = "8.4"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_max_allocated_storage" {
  description = "Storage autoscaling ceiling in GiB"
  type        = number
  default     = 100
}

variable "db_name" {
  type    = string
  default = "fruitbazar"
}

variable "db_username" {
  type    = string
  default = "fruitbazar_app"
}

variable "db_multi_az" {
  description = "Standby replica in a second AZ (roughly doubles DB cost)"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = false
}

# --------------------------------------------------------- domain / DNS ---
variable "domain_name" {
  description = "Domain registered at Hostinger (e.g. fruitbazar.in). Leave empty to serve over HTTP on the ALB hostname only."
  type        = string
  default     = ""
}

variable "dns_mode" {
  description = <<-EOT
    How DNS is wired to the domain at Hostinger:
      route53   - Terraform creates a Route 53 zone and switches the domain's
                  nameservers at Hostinger to it via the Hostinger API.
                  Apex (example.com) AND www both work. Existing Hostinger DNS
                  records (e.g. email MX) must be re-created via additional_dns_records.
      hostinger - DNS stays at Hostinger. Terraform adds a CNAME for
                  app_subdomain (default www) -> ALB, plus the ACM validation
                  record, via the Hostinger API. Existing records are untouched.
                  The apex is forwarded to https://www.<domain>.
  EOT
  type        = string
  default     = "route53"
  validation {
    condition     = contains(["route53", "hostinger"], var.dns_mode)
    error_message = "dns_mode must be \"route53\" or \"hostinger\"."
  }
}

variable "app_subdomain" {
  description = "Subdomain for the site in hostinger mode (a CNAME cannot sit on the apex)"
  type        = string
  default     = "www"
  validation {
    condition     = var.dns_mode != "hostinger" || length(var.app_subdomain) > 0
    error_message = "In hostinger dns_mode, app_subdomain must be set (e.g. \"www\")."
  }
}

variable "hostinger_forward_apex" {
  description = "hostinger mode only: 301-forward the bare domain to https://<app_subdomain>.<domain>"
  type        = bool
  default     = true
}

variable "additional_dns_records" {
  description = "route53 mode only: extra records to recreate (e.g. Hostinger email MX/TXT)"
  type = list(object({
    name    = string # "" for apex, or "mail", etc.
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}
