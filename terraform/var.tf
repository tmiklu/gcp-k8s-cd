variable "project" { 
  type = string
}

variable "credentials_file" { }

variable "master_ver" {
  type = string
  default = "1.17.14-gke.1600"
}