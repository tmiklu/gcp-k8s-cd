terraform {
  required_version = "~> 0.14"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.51.0"
    }
  }
}

provider "google" {

  credentials = file(var.credentials_file)

  project = var.project
}

resource "google_container_cluster" "primary" {
  name               = "multi-zonal-cluster"
  location           = "europe-west3-a" //master|control plane in europe-west3-a
  network            = "default"
  subnetwork         = "default"

  min_master_version = var.master_ver

  release_channel {
    channel = var.channel
  }
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  // creates three worker nodes, "a" is not required because is specified in location
  node_locations = [
    "europe-west3-b",
    "europe-west3-c",
  ]

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }

  }

}

resource "google_container_node_pool" "nodes" {
  name       = "my-node-pool"
  location   = "europe-west3-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  
  // required for RAPID release channel
  management {
    auto_upgrade = true
    auto_repair  = true
  }

  //autoscaling {
  //  min_node_count = 3
  //  max_node_count = 5
  //}

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
