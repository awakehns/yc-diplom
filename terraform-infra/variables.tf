variable "cloud_id" {
  description = "ID облака"
  type        = string
}

variable "folder_id" {
  description = "ID каталога"
  type        = string
}

variable "zone" {
  description = "Зона доступности по умолчанию"
  type        = string
  default     = "ru-central1-a"
}

variable "sa_key_file" {
  description = "Путь к JSON-ключу сервисного аккаунта terraform (создаётся в terraform-bootstrap)"
  type        = string
  default     = "../terraform-bootstrap/terraform-sa-key.json"
}

variable "k8s_version" {
  description = "Версия Kubernetes для master и node group"
  type        = string
  default     = "1.32"
}

# Параметры worker-нод. Минимальные значения для экономии бюджета.
variable "node_cores" {
  description = "Количество vCPU на ноду"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "Объём RAM на ноду, ГБ"
  type        = number
  default     = 4
}

variable "node_core_fraction" {
  description = "Гарантированная доля vCPU, %"
  type        = number
  default     = 50
}

variable "node_disk_size" {
  description = "Размер диска ноды, ГБ"
  type        = number
  default     = 64
}

variable "node_count_min" {
  description = "Минимальное количество worker-нод"
  type        = number
  default     = 2
}

variable "node_count_max" {
  description = "Максимальное количество worker-нод"
  type        = number
  default     = 4
}
