output "k8s_cluster_host" {
  description = "Cluster API IP"
  value       = google_container_cluster.k8s_cluster.endpoint
}
