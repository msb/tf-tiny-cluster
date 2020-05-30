# variables.tf contains definitions of variables used by the module.

# The name of the cluster.
variable "cluster_name" {
  default = "tiny-cluster"
}

# The cluster's zone (we only specify the zone to keep the cluster to a single node).
variable "cluster_zone" {
  default = "europe-west1-b"
}

# The name of the node pool.
variable "node_pool_name" {
  default = "node-pool-single-small"
}

# The node specification.
variable "machine_type" {
  default = "g1-small"
}
