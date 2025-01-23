variable "atlantis_web_username" {
    type = string
    sensitive = true
    description = "atlantis server --web-username"
}

variable "atlantis_web_password" {
    type = string
    sensitive = true
    description = "atlantis server --web-password"
}
