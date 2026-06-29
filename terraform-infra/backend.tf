terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    region   = "ru-central1"
    key      = "infra/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}
