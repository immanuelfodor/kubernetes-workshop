provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "k8s_vpc" {
  name                    = "k8s-vpc-${terraform.workspace}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_subnet" {
  name                     = "k8s-subnet-${terraform.workspace}"
  region                   = var.region
  network                  = google_compute_network.k8s_vpc.name
  ip_cidr_range            = "10.10.10.0/24"
  private_ip_google_access = true
}

# @see: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "k8s_cluster" {
  name     = "k8s-cluster-${terraform.workspace}"
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.k8s_vpc.self_link
  subnetwork = google_compute_subnetwork.k8s_subnet.self_link

  network_policy {
    enabled = true
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "k8s_preemptible_nodes" {
  name       = "k8s-node-pool-${terraform.workspace}"
  location   = var.zone
  cluster    = google_container_cluster.k8s_cluster.name
  node_count = 3

  node_config {
    preemptible  = true # only lasts 24 hours max, lower price, @see: https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms
    machine_type = "e2-medium"
    disk_size_gb = 20
    image_type   = "UBUNTU_CONTAINERD"

    tags = ["k8s-node"]

    labels = {
      env = var.project_id
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# @see: https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
resource "google_compute_firewall" "allow_console_ssh" {
  name    = "allow-browser-console-ssh-through-iap-${terraform.workspace}"
  network = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = google_container_node_pool.k8s_preemptible_nodes.node_config[0].tags
}
