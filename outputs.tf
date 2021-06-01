output "private_dns" {
  value = {
    pdm_service_discovery_dns = aws_service_discovery_private_dns_namespace.pdm_services
    pdm_service_discovery     = aws_service_discovery_service.pdm_services
  }
}
