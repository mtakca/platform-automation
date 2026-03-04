terraform {
  required_version = ">= 1.7.0"

  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "~> 3.14"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.10"
    }
  }
}
