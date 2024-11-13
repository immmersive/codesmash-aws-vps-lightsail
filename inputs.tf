variable "app_name" {    
    default     = ""
}
 
variable "region" {
    default     = ""
}

variable "availability_zone" {
    default     = ""
}

variable "blueprint_id" {    
    default     = ""
}
 
variable "bundle_id" {
    default     = ""
}

variable "has_static_ip" {
    default     = "false"
}

variable "lb_instances" {
    type =      list(string)
    default     = []
}

variable "has_distribution" {
    default     = "true"
}

variable "distribution_size" {
    default     = "small_1_0"
}

variable "distribution_cache_behavior" {
    default     = "dont-cache"
}
