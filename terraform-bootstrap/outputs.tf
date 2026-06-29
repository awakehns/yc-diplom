output "service_account_id" {
  description = "ID сервисного аккаунта для Terraform"
  value       = yandex_iam_service_account.terraform.id
}

output "sa_key_file_path" {
  description = "Путь к JSON-ключу сервисного аккаунта (используется в terraform-infra)"
  value       = local_file.terraform_sa_key.filename
}

output "bucket_name" {
  description = "Имя S3 бакета для terraform state"
  value       = yandex_storage_bucket.tf_state.bucket
}

output "static_access_key" {
  description = "Access key для S3 backend"
  value       = yandex_iam_service_account_static_access_key.s3_key.access_key
  sensitive   = true
}

output "static_secret_key" {
  description = "Secret key для S3 backend"
  value       = yandex_iam_service_account_static_access_key.s3_key.secret_key
  sensitive   = true
}
