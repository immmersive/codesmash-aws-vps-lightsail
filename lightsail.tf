resource "aws_lightsail_instance" "lightsail" {
    name                = "${var.app_name}_${terraform.workspace}"
    availability_zone   = "${var.availability_zone}" 
    blueprint_id        = "${var.blueprint_id}" 
    bundle_id           = "${var.bundle_id}" 
    user_data           = file("user_data.sh")
}
