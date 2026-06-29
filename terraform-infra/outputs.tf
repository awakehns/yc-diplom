output "cluster_id" {
  description = "ID Kubernetes-кластера"
  value       = yandex_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Имя Kubernetes-кластера"
  value       = yandex_kubernetes_cluster.main.name
}

output "external_v4_endpoint" {
  description = "Внешний endpoint master"
  value       = yandex_kubernetes_cluster.main.master[0].external_v4_endpoint
}

output "network_id" {
  description = "ID VPC"
  value       = yandex_vpc_network.main.id
}

output "subnet_ids" {
  description = "ID подсетей по зонам a/b/d"
  value = [
    yandex_vpc_subnet.subnet_a.id,
    yandex_vpc_subnet.subnet_b.id,
    yandex_vpc_subnet.subnet_d.id,
  ]
}

output "registry_id" {
  description = "ID Container Registry"
  value       = yandex_container_registry.main.id
}

output "registry_url" {
  description = "URL для docker push/pull"
  value       = "cr.yandex/${yandex_container_registry.main.id}"
}

output "cicd_sa_key_file" {
  description = "Путь к JSON-ключу CI/CD SA"
  value       = local_file.cicd_sa_key.filename
}
