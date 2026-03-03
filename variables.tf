variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"  
}

variable "github_repo" {
  type        = string
  description = "The GitHub repository in the format 'username/repo-name'"
  default     = "vishnusp7578/tf-secure-pipeline-githubactions"
}
