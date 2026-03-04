provider "vcd" {
  url                  = var.vcd_url
  org                  = var.org_name
  token                = var.vcd_access_token
  auth_type            = "token"
  allow_unverified_ssl = true 
  max_retry_timeout    = 600
}

provider "opnsense" {
  uri                  = "https://${var.opnsense_ip}"
  api_key              = var.opnsense_api_key
  api_secret           = var.opnsense_api_secret
}