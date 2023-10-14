listener "tcp" {
  address  = "0.0.0.0:8200"
  tls_disable  = 1
}

storage "postgresql" {
  connection_url = "postgresql://vault:PASSWORD@postgres:5432/vault?sslmode=disable"
}

ui = true
cluster_name = "sol.milkyway"
default_lease_ttl = "8765h"
max_lease_ttl = "87600h"
api_addr = "https://atlas.sol.milkyway/"
