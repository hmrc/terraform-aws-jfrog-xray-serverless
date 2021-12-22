output "artifactory_url" {
  value = "http://${aws_lb.artifactory.dns_name}"
}
