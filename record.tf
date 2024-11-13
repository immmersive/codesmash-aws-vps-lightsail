resource "aws_route53_zone" "domain" {
    count   = var.domain != "" ? 1 : 0
    name    = var.domain
}
 
resource "aws_route53_record" "distribution_record" {
    for_each    = var.domain != "" && length(var.subdomains) > 0 ? toset(var.subdomains) : toset([])
    zone_id     = aws_route53_zone.domain[0].zone_id
    name        = "${each.value}.${var.domain}"
    type        = "CNAME"
    ttl         = 300
    records     = [aws_lightsail_distribution.distribution[0].domain_name]
}  
