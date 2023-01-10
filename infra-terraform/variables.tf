variable "domain" {
  description = "(Raíz do) domínio a ser usado"
  type        = string
}

variable "delegation_set" {
  description = "Conjunto de nameservers a usar no domínio."
  type        = string
}
