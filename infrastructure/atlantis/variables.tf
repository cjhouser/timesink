variable "atlantis_web_username" {
    type = string
    sensitive = true
    description = "ATLANTIS_WEB_USERNAME"
}

variable "atlantis_web_password" {
    type = string
    sensitive = true
    description = "ATLANTIS_WEB_PASSWORD"
}

variable "atlantis_gh_webhook_secret" {
    type = string
    sensitive = true
    description = "ATLANTIS_GH_WEBHOOK_SECRET"
}

variable "atlantis_gh_token" {
    type = string
    sensitive = true
    description = "ATLANTIS_GH_TOKEN"
}
