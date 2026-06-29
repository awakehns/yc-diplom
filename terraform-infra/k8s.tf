resource "yandex_iam_service_account" "k8s_sa" {
  name      = "k8s-sa"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_roles" {
  for_each = toset([
    "k8s.clusters.agent",
    "vpc.publicAdmin",
    "load-balancer.admin",
    "container-registry.images.puller"
  ])

  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_kubernetes_cluster" "main" {
  name        = "k8s-cluster"
  description = "Managed Kubernetes cluster"
  network_id  = yandex_vpc_network.main.id

  master {
    version = var.k8s_version

    zonal {
      zone      = yandex_vpc_subnet.subnet_a.zone
      subnet_id = yandex_vpc_subnet.subnet_a.id
    }

    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  release_channel = "REGULAR"

  depends_on = [yandex_resourcemanager_folder_iam_member.k8s_sa_roles]
}

resource "yandex_kubernetes_node_group" "main" {
  cluster_id = yandex_kubernetes_cluster.main.id
  name       = "worker-pool"
  version    = var.k8s_version

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = var.node_cores
      memory        = var.node_memory
      core_fraction = var.node_core_fraction
    }

    boot_disk {
      type = "network-hdd"
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      nat        = true
      subnet_ids = [
        yandex_vpc_subnet.subnet_a.id,
        yandex_vpc_subnet.subnet_b.id,
        yandex_vpc_subnet.subnet_d.id,
      ]
    }
  }

  scale_policy {
      fixed_scale {
        size = var.node_count_min
      }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
    location {
      zone = "ru-central1-b"
    }
    location {
      zone = "ru-central1-d"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "03:00"
      duration   = "3h"
    }
  }
}
