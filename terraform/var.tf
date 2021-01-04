variable "project" { 
  type = string
}

variable "credentials_file" { }

variable "master_ver" {
  type    = string
  default = "1.18.12-gke.1201"
}

variable "channel" {
  type    = string
  default = "RAPID"
}