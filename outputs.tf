output "project_id" {
  value       = google_container_cluster.primary.project
  description = "The id of the cluster's project."
}

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the cluster."
}

output "cluster_zone" {
  value       = google_container_cluster.primary.location
  description = "The zone of the cluster."
}
