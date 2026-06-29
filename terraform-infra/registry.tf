resource "yandex_container_registry" "main" {
  name      = "diploma-registry"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "cicd_sa" {
  name      = "cicd-sa"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "cicd_registry_push" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.cicd_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "cicd_k8s_deploy" {
  folder_id = var.folder_id
  role      = "k8s.editor"
  member    = "serviceAccount:${yandex_iam_service_account.cicd_sa.id}"
}

resource "yandex_iam_service_account_key" "cicd_key" {
  service_account_id = yandex_iam_service_account.cicd_sa.id
  description        = "Key for CI/CD pipeline"
}

resource "local_file" "cicd_sa_key" {
  filename        = "${path.module}/cicd-sa-key.json"
  file_permission = "0600"

  content = jsonencode({
    id                 = yandex_iam_service_account_key.cicd_key.id
    service_account_id = yandex_iam_service_account_key.cicd_key.service_account_id
    created_at         = yandex_iam_service_account_key.cicd_key.created_at
    key_algorithm      = yandex_iam_service_account_key.cicd_key.key_algorithm
    public_key         = yandex_iam_service_account_key.cicd_key.public_key
    private_key        = yandex_iam_service_account_key.cicd_key.private_key
  })
}
