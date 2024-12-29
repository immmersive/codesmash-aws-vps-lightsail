resource "aws_lightsail_instance" "lightsail" {
    name                = "${var.app_name}_${terraform.workspace}"
    availability_zone   = "${var.availability_zone}" 
    blueprint_id        = "${var.blueprint_id}" 
    bundle_id           = "${var.bundle_id}"  
    user_data = <<EOT
${var.selected_app != "" ? file("images/${var.selected_app}") : ""}
${file("user_data.sh")}
EOT
}
