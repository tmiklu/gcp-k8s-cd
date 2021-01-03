terraform {
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

resource "google_compute_subnetwork" "vpc_gke" {
  name          = "gke-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "europe-west3"
  network       = google_compute_network.vpc_gke.name
}

resource "google_compute_network" "vpc_gke" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "primary" {
  name       = "gke-cluster"
  location   = "europe-west3"
  network    = "gke-network"
  subnetwork = "gke-subnetwork"
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }

  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "europe-west3"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  management {
    auto_upgrade = false
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 5
  }

  //node_locations = [
  //  "europe-west3-c",
  //]

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
