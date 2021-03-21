provider "google" {
 credentials = var.credentials
 project     = var.project
 region      = var.region
 user_project_override = true
}

#resource "google_app_engine_application" "app" {
#  project     = "agile-planet-308222"
#  location_id = "us-central"
#}

resource "google_project_service" "project" {
  project = var.project
  service = "iam.googleapis.com"
  disable_dependent_services = true
}

resource "google_compute_firewall" "default" {
  name    = "pinguen-rules"
  project =  var.project
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "3000", "5432"]
  }
 }

resource "google_sql_database_instance" "postgres" {
  name             = "postgre-sql"
  project          = var.project
  database_version = "POSTGRES_9_6"
  region           = var.region

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "users" {
  name             = "gogs"
  project          = var.project
  instance         = google_sql_database_instance.postgres.name
  password         = "gogs"
  depends_on       = [google_sql_database_instance.postgres]
}

resource "google_sql_database" "database" {
  name             = "gogs"
  project          = var.project
  instance         = google_sql_database_instance.postgres.name
  depends_on       = [google_sql_database_instance.postgres]
}
