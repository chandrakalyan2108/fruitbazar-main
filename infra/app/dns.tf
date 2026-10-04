###############################################################################
# Domain at Hostinger -> AWS
#
#   dns_mode = "route53"  : Route 53 zone + Hostinger nameservers switched by API
#                           (apex + www both served, ALIAS records to the ALB)
#   dns_mode = "hostinger": DNS stays at Hostinger, records upserted by API
#                           (www CNAME -> ALB, apex 301-forwarded to www)
#
# The Hostinger API token is read from the HOSTINGER_API_TOKEN environment
# variable by scripts/hostinger-dns.sh, so it never lands in Terraform state.
###############################################################################

# ---------------------------------------------------------------- ACM -------
resource "aws_acm_certificate" "app" {
  count             = local.use_domain ? 1 : 0
  domain_name       = local.app_fqdn
  validation_method = "DNS"

  # route53 mode serves both apex and www
  subject_alternative_names = local.use_route53 ? ["www.${var.domain_name}"] : []

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cert_validations = {
    for dvo in flatten(aws_acm_certificate.app[*].domain_validation_options) : dvo.domain_name => {
      fqdn  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

# ------------------------------------------------------ route53 mode --------
resource "aws_route53_zone" "main" {
  count   = local.use_route53 ? 1 : 0
  name    = var.domain_name
  comment = "Managed by Terraform - delegated from Hostinger"
}

# Point the domain (registered at Hostinger) at the Route 53 nameservers.
resource "terraform_data" "hostinger_nameservers" {
  count = local.use_route53 ? 1 : 0

  triggers_replace = [var.domain_name, join(",", sort(aws_route53_zone.main[0].name_servers))]

  provisioner "local-exec" {
    command = "bash '${local.hostinger_script}' set-nameservers '${var.domain_name}' ${join(" ", sort(aws_route53_zone.main[0].name_servers))}"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each        = local.use_route53 ? local.cert_validations : {}
  zone_id         = aws_route53_zone.main[0].zone_id
  name            = each.value.fqdn
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_route53_record" "apex" {
  count   = local.use_route53 ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  count   = local.use_route53 ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# Re-create anything you had at Hostinger DNS (email MX/TXT/SPF, etc.)
resource "aws_route53_record" "additional" {
  for_each = local.use_route53 ? { for r in var.additional_dns_records : "${r.name}-${r.type}" => r } : {}
  zone_id  = aws_route53_zone.main[0].zone_id
  name     = each.value.name == "" ? var.domain_name : "${each.value.name}.${var.domain_name}"
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.records
}

# ----------------------------------------------------- hostinger mode -------
resource "terraform_data" "hostinger_cert_validation" {
  for_each = local.use_hostinger_dns ? local.cert_validations : {}

  # Hostinger wants the record name relative to the zone, without trailing dots
  input = {
    script = local.hostinger_script
    domain = var.domain_name
    name   = trimsuffix(trimsuffix(each.value.fqdn, "."), ".${var.domain_name}")
    type   = each.value.type
    value  = trimsuffix(each.value.value, ".")
  }
  triggers_replace = [each.value.fqdn, each.value.value]

  provisioner "local-exec" {
    command = "bash '${self.input.script}' upsert-record '${self.input.domain}' '${self.input.name}' '${self.input.type}' '${self.input.value}' 300"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "bash '${self.input.script}' delete-record '${self.input.domain}' '${self.input.name}' '${self.input.type}'"
  }
}

resource "terraform_data" "hostinger_app_record" {
  count = local.use_hostinger_dns ? 1 : 0

  input = {
    script = local.hostinger_script
    domain = var.domain_name
    name   = var.app_subdomain
    target = aws_lb.main.dns_name
  }
  triggers_replace = [var.app_subdomain, aws_lb.main.dns_name]

  provisioner "local-exec" {
    command = "bash '${self.input.script}' upsert-record '${self.input.domain}' '${self.input.name}' CNAME '${self.input.target}' 300"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "bash '${self.input.script}' delete-record '${self.input.domain}' '${self.input.name}' CNAME"
  }
}

resource "terraform_data" "hostinger_apex_forward" {
  count = local.use_hostinger_dns && var.hostinger_forward_apex ? 1 : 0

  input = {
    script = local.hostinger_script
    domain = var.domain_name
    target = "https://${local.app_fqdn}"
  }
  triggers_replace = [local.app_fqdn]

  provisioner "local-exec" {
    command = "bash '${self.input.script}' forward-apex '${self.input.domain}' '${self.input.target}'"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "bash '${self.input.script}' delete-forward '${self.input.domain}'"
  }
}

# --------------------------------------------- wait for the certificate -----
resource "aws_acm_certificate_validation" "app" {
  count                   = local.use_domain ? 1 : 0
  certificate_arn         = aws_acm_certificate.app[0].arn
  validation_record_fqdns = local.use_route53 ? [for r in aws_route53_record.cert_validation : r.fqdn] : null

  # Nameserver changes at the registry can take a while to propagate
  timeouts {
    create = "90m"
  }

  depends_on = [
    terraform_data.hostinger_nameservers,
    terraform_data.hostinger_cert_validation,
  ]
}
