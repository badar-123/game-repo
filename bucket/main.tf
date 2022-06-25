resource "google_storage_bucket" "staging_bucket_test" {
  name          = "Staging_bucket_test"
  storage_class = "STANDARD"
  project       = var.project_id
  location      = var.location

 lifecycle_rule {
      condition {
        age = 0
      }
      action {
        type = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    }
	
	lifecycle_rule {
      condition {
        age = 90
      }
      action {
        type = "SetStorageClass"
        storage_class = "COLDLINE"
      }
    }
    lifecycle_rule {
      condition {
        age = 180
      }
      action {
        type = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
    }
}
resource "google_storage_bucket_iam_member" "bucket_iam" {
  bucket     = google_storage_bucket.staging_bucket_test.name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
  depends_on = [google_storage_bucket.staging_bucket_test]
}

resource "google_storage_transfer_job" "move_files" {
  description = "Moving older files from TRIGGER bucket to Staging bucket"
  project     = var.project_id

  transfer_spec {
    object_conditions {
      max_time_elapsed_since_last_modification = "300s"
    }
    transfer_options {
      delete_objects_unique_in_sink = false
    }
    gcs_data_source {
      bucket_name = google_storage_bucket.old_files_bucket.name
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.staging_bucket_test.name
      path        = "foo/bar/"
    }
  }

  schedule {
    schedule_start_date {
      year  = 2022
      month = 06
      day   = 24
    }
    schedule_end_date {
      year  = 2022
      month = 07
      day   = 24
    }
    start_time_of_day {
      hours   = 23
      minutes = 30
      seconds = 0
      nanos   = 0
    }
    repeat_interval = "60s"
  }

  depends_on = [google_storage_bucket_iam_member.bucket_iam]
}