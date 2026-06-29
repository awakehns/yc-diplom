terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.122.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.token
}

resource "yandex_iam_service_account" "terraform" {
  name        = var.sa_name
  description = "Service account used by Terraform to manage infrastructure"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_admin" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_iam_service_account_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description         = "Key for terraform provider authentication"
  key_algorithm       = "RSA_4096"
}

resource "local_file" "terraform_sa_key" {
  filename        = "${path.module}/terraform-sa-key.json"
  file_permission = "0600"

  content = jsonencode({
    id                  = yandex_iam_service_account_key.terraform_key.id
    service_account_id = yandex_iam_service_account_key.terraform_key.service_account_id
    created_at          = yandex_iam_service_account_key.terraform_key.created_at
    key_algorithm       = yandex_iam_service_account_key.terraform_key.key_algorithm
    public_key          = yandex_iam_service_account_key.terraform_key.public_key
    private_key         = yandex_iam_service_account_key.terraform_key.private_key
  })
}

resource "yandex_iam_service_account_static_access_key" "s3_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description         = "Static access key for S3-compatible Terraform backend"
}

resource "yandex_storage_bucket" "tf_state" {
  access_key    = yandex_iam_service_account_static_access_key.s3_key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.s3_key.secret_key
  bucket        = var.bucket_name
  force_destroy = true

  versioning {
    enabled = true
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.terraform_admin]
}

resource "null_resource" "bucket_cleanup" {
  triggers = {
    bucket_name = var.bucket_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      set -e
      BUCKET="${self.triggers.bucket_name}"

      echo "Deleting all objects in $BUCKET..."
      OBJECTS=$(yc storage s3api list-objects --bucket "$BUCKET" \
        --query 'Contents[].Key' --output json 2>/dev/null || echo "[]")

      echo "$OBJECTS" | \
        grep -v '^\[\]$' | \
        jq -r '.[]' 2>/dev/null | \
        while read KEY; do
          echo "  deleting object: $KEY"
          yc storage s3api delete-object --bucket "$BUCKET" --key "$KEY"
        done

      echo "Bucket $BUCKET cleaned."
    EOT
  }

  depends_on = [yandex_storage_bucket.tf_state]
}
