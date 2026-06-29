variable "cloud_id" {
  description = "ID облака в Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога (folder), в котором создаются ресурсы"
  type        = string
}

variable "zone" {
  description = "Зона доступности по умолчанию"
  type        = string
  default     = "ru-central1-a"
}

variable "sa_name" {
  description = "Имя сервисного аккаунта для Terraform"
  type        = string
  default     = "terraform-sa"
}

variable "bucket_name" {
  description = "Имя S3 бакета для хранения terraform state"
  type        = string
}

variable "token" {
  description = "Токен для доступа к аккаунту yandex cloud"
  type        = string
}
