resource "aws_lightsail_static_ip" "static_ip" {
    count = var.has_static_ip == "true" ? 1 : 0

    name = "static_ip_${var.app_name}_${terraform.workspace}"
}
 
resource "aws_lightsail_static_ip_attachment" "static_ip_attachment" {
    count = var.has_static_ip == "true" ? 1 : 0

    static_ip_name = aws_lightsail_static_ip.static_ip[0].name 
    instance_name  = aws_lightsail_instance.lightsail.name
}
