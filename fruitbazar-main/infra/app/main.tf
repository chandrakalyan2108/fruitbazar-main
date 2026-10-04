data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  use_domain        = var.domain_name != ""
  use_route53       = local.use_domain && var.dns_mode == "route53"
  use_hostinger_dns = local.use_domain && var.dns_mode == "hostinger"

  # Primary hostname the site is served on
  app_fqdn = (
    !local.use_domain ? "" :
    local.use_route53 ? var.domain_name :
    "${var.app_subdomain}.${var.domain_name}"
  )

  hostinger_script = abspath("${path.module}/../../scripts/hostinger-dns.sh")
}
