output "provider_name" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "sa_email" {
  value = google_service_account.sa.email
}

output "iam_roles_created" {
  value = true
}
