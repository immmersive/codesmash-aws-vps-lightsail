output "instance_name" {
  value = aws_lightsail_instance.lightsail.name
}

output "lightsail_static_ip" {  
  value         = var.has_static_ip == "true" ? aws_lightsail_static_ip.static_ip[0].ip_address : null
}
