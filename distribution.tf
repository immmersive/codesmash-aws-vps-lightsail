resource "aws_lightsail_distribution" "distribution" {
    count = var.has_distribution == "true" ? 1 : 0

    name                     = "distribution_${var.app_name}_${terraform.workspace}"
    bundle_id                = var.distribution_size
 
    origin {
        name                 = aws_lightsail_instance.lightsail.name 
        protocol_policy      = "http-only" 
        region_name          = var.region
    }

    cache_behavior_settings {
        allowed_http_methods = "GET,HEAD,OPTIONS,PUT,PATCH,POST,DELETE"
        cached_http_methods  = "GET,HEAD"
        default_ttl          = 86400
        maximum_ttl          = 31536000
        minimum_ttl          = 0

        forwarded_cookies {
            option = "none"
        }

        forwarded_headers {
            option = "default"
        }

        forwarded_query_strings {
            option = false
        }
    }
 
    default_cache_behavior {
        behavior = var.distribution_cache_behavior
    }

    lifecycle {
        ignore_changes = [certificate_name]  
    }
}
