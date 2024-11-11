resource "aws_lightsail_lb" "load_balancer" {
  count             = length(var.lb_instances) > 0 ? 1 : 0
  name              = "load_balancer_${var.app_name}_${terraform.workspace}"
  health_check_path = "/"
  instance_port     = "80"
}

resource "aws_lightsail_lb_attachment" "lb_attachments" {
  for_each      = length(var.lb_instances) > 0 ? toset(var.lb_instances) : []
  lb_name       = aws_lightsail_lb.load_balancer[0].name
  instance_name = each.value
}
