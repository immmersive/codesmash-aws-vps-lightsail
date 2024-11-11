output "instance_name" {
  value = aws_lightsail_instance.lightsail.name
}

output "lightsail_static_ip" {  
  value         = var.has_static_ip == "true" ? aws_lightsail_static_ip.static_ip[0].ip_address : null
}

output "load_balancer_dns" {
  value         = length(var.lb_instances) > 0 ? aws_lightsail_lb.load_balancer[0].dns_name : null
}

output "lb_instances" {
  value         = var.lb_instances
}
