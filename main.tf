locals {
  location = lookup(local.default, "cluster_zone", "europe-west1-b")
}

# The cluster with a single node(note that location must be scoped to particular zone or k8s will
# create nodes over the zones in the region).
resource "google_container_cluster" "primary" {
  name     = lookup(local.default, "cluster_name", "tiny-cluster")
  location = local.location

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

# The cluster's default node pool (sized to 1)
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = lookup(local.default, "node_pool_name", "node-pool-single-small")
  location   = local.location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = lookup(local.default, "machine_type", "g1-small")
    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
