variable "account_id" {
  type        = string
  description = "Cloudflare account that owns the tunnel"
}

variable "tunnel_name" {
  type        = string
  default     = "tks-ingress"
  description = "Name of the tunnel"
}

variable "service" {
  type        = string
  default     = "https://gateway.istio-gateway.svc.cluster.local:443"
  description = "Where cloudflared sends every public hostname: the shared Istio ingress gateway"
}

variable "hostnames" {
  type        = list(string)
  description = "Public hostnames routed through the tunnel. Internal *.sol.milkyway names never belong here"

  validation {
    condition     = length(var.hostnames) == length(distinct(var.hostnames))
    error_message = "Each hostname can only be listed once."
  }
}
