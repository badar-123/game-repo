	variable "project_id" {
	  description = "The ID of the project to create the bucket in."
	  type        = string
	}
	

	variable "location" {
	  description = "The location of the bucket."
	  type        = string
	}
	

	variable "google_storage_bucket" {
		description = "data source bucket"
		type	    = string
	  
	}
				