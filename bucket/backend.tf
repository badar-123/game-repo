terraform {
  backend "gcs" {
    bucket  = "old_files_bucket"
  }
}